package cmd_test

import (
	"bytes"
	"context"
	"encoding/json"
	"path/filepath"
	"strings"
	"testing"

	"faciqor/internal/client"
	"faciqor/internal/cmd"
	v1 "faciqor/pkg/api/v1"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type mockIdentityClient struct {
	unverified bool
	profile    *v1.UserProfileResponse
	orgs       map[string]*v1.OrganizationResponse
}

func newMockClient(unverified bool) *mockIdentityClient {
	return &mockIdentityClient{
		unverified: unverified,
		profile: &v1.UserProfileResponse{
			Id:            "user-uuid-1",
			Email:         "max.mustermann@example.com",
			Handle:        "max-mustermann",
			EmailVerified: !unverified,
			InsertedAt:    "2026-10-23T19:00:00Z",
		},
		orgs: make(map[string]*v1.OrganizationResponse),
	}
}

func (m *mockIdentityClient) checkGate() error {
	if m.unverified {
		return status.Error(codes.PermissionDenied, "Email verification required for API and CLI access")
	}
	return nil
}

func (m *mockIdentityClient) GetMyProfile(ctx context.Context, in *v1.GetMyProfileRequest, opts ...grpc.CallOption) (*v1.UserProfileResponse, error) {
	if err := m.checkGate(); err != nil {
		return nil, err
	}
	return m.profile, nil
}

func (m *mockIdentityClient) UpdateMyProfile(ctx context.Context, in *v1.UpdateMyProfileRequest, opts ...grpc.CallOption) (*v1.UserProfileResponse, error) {
	if err := m.checkGate(); err != nil {
		return nil, err
	}
	m.profile.Handle = in.Handle
	return m.profile, nil
}

func (m *mockIdentityClient) RequestAccountDeletion(ctx context.Context, in *v1.RequestAccountDeletionRequest, opts ...grpc.CallOption) (*v1.RequestAccountDeletionResponse, error) {
	if err := m.checkGate(); err != nil {
		return nil, err
	}
	handles := make([]string, 0, len(m.orgs))
	for h := range m.orgs {
		handles = append(handles, h)
	}
	return &v1.RequestAccountDeletionResponse{
		PurgeScheduledAt:            "2026-12-22T19:00:00Z",
		OrphanedOrganizationHandles: handles,
	}, nil
}

func (m *mockIdentityClient) CreateOrganization(ctx context.Context, in *v1.CreateOrganizationRequest, opts ...grpc.CallOption) (*v1.OrganizationResponse, error) {
	if err := m.checkGate(); err != nil {
		return nil, err
	}
	org := &v1.OrganizationResponse{
		Id:           "org-uuid-" + in.Handle,
		Handle:       in.Handle,
		PrimaryFocus: in.PrimaryFocus,
		MyRole:       v1.MembershipRole_MEMBERSHIP_ROLE_OWNER,
		CountryCode:  "DE",
	}
	if in.DisplayName != nil {
		org.DisplayName = *in.DisplayName
	}
	if in.LegalName != nil {
		org.LegalName = *in.LegalName
	}
	m.orgs[in.Handle] = org
	return org, nil
}

func (m *mockIdentityClient) ListMyOrganizations(ctx context.Context, in *v1.ListMyOrganizationsRequest, opts ...grpc.CallOption) (*v1.ListMyOrganizationsResponse, error) {
	if err := m.checkGate(); err != nil {
		return nil, err
	}
	list := make([]*v1.OrganizationResponse, 0, len(m.orgs))
	for _, o := range m.orgs {
		list = append(list, o)
	}
	return &v1.ListMyOrganizationsResponse{Organizations: list}, nil
}

func (m *mockIdentityClient) GetOrganization(ctx context.Context, in *v1.GetOrganizationRequest, opts ...grpc.CallOption) (*v1.OrganizationResponse, error) {
	if err := m.checkGate(); err != nil {
		return nil, err
	}
	org, ok := m.orgs[in.IdOrHandle]
	if !ok {
		return nil, status.Error(codes.NotFound, "organization not found")
	}
	return org, nil
}

func (m *mockIdentityClient) UpdateOrganization(ctx context.Context, in *v1.UpdateOrganizationRequest, opts ...grpc.CallOption) (*v1.OrganizationResponse, error) {
	if err := m.checkGate(); err != nil {
		return nil, err
	}
	org, ok := m.orgs[in.IdOrHandle]
	if !ok {
		return nil, status.Error(codes.NotFound, "organization not found")
	}
	if in.LegalName != nil {
		org.LegalName = *in.LegalName
	}
	if in.TaxId != nil {
		org.TaxId = *in.TaxId
	}
	if in.Handle != nil && *in.Handle != org.Handle {
		delete(m.orgs, org.Handle)
		org.Handle = *in.Handle
		m.orgs[org.Handle] = org
	}
	return org, nil
}

func (m *mockIdentityClient) SoftDeleteOrganization(ctx context.Context, in *v1.SoftDeleteOrganizationRequest, opts ...grpc.CallOption) (*v1.OrganizationResponse, error) {
	if err := m.checkGate(); err != nil {
		return nil, err
	}
	org, ok := m.orgs[in.IdOrHandle]
	if !ok {
		return nil, status.Error(codes.NotFound, "organization not found")
	}
	now := "2026-10-23T19:30:00Z"
	org.DeletedAt = &now
	return org, nil
}

func runCLI(t *testing.T, mock *mockIdentityClient, configPath string, args ...string) (string, error) {
	t.Helper()
	factory := func(endpoint, token string) (v1.IdentityServiceClient, func() error, error) {
		return mock, func() error { return nil }, nil
	}
	opts := &cmd.Options{
		ConfigPath:    configPath,
		ClientFactory: client.Factory(factory),
	}
	root := cmd.NewRootCmd(opts)
	buf := new(bytes.Buffer)
	root.SetOut(buf)
	root.SetErr(buf)
	root.SetArgs(args)
	err := root.Execute()
	return buf.String(), err
}

func TestUnverifiedUserBlockedWithPermissionDenied(t *testing.T) {
	tmpConfig := filepath.Join(t.TempDir(), "config.yaml")
	mock := newMockClient(true)

	_, err := runCLI(t, mock, tmpConfig, "auth", "login", "--token", "fq_pat_unverified")
	if err == nil {
		t.Fatalf("expected error for unverified user, got nil")
	}
	if !strings.Contains(err.Error(), "PermissionDenied") && !strings.Contains(err.Error(), "Email verification required") {
		t.Fatalf("expected PermissionDenied error, got: %v", err)
	}
}

func TestFullVerifiedCLIWorkflow(t *testing.T) {
	tmpConfig := filepath.Join(t.TempDir(), "config.yaml")
	mock := newMockClient(false)

	// 1. faciqor auth login --token <pat>
	out, err := runCLI(t, mock, tmpConfig, "auth", "login", "--token", "fq_pat_test123")
	if err != nil {
		t.Fatalf("auth login failed: %v", err)
	}
	if !strings.Contains(out, "@max-mustermann") {
		t.Fatalf("expected @max-mustermann in output, got: %s", out)
	}

	// 2. faciqor org create --handle meine-hv --focus manager
	out, err = runCLI(t, mock, tmpConfig, "org", "create", "--handle", "meine-hv", "--focus", "manager")
	if err != nil {
		t.Fatalf("org create failed: %v", err)
	}
	if !strings.Contains(out, "@meine-hv") {
		t.Fatalf("expected @meine-hv in output, got: %s", out)
	}

	// 3. faciqor org update meine-hv --legal-name "Muster Hausverwaltung GmbH" --tax-id "12/345/67890"
	out, err = runCLI(t, mock, tmpConfig, "org", "update", "meine-hv", "--legal-name", "Muster Hausverwaltung GmbH", "--tax-id", "12/345/67890")
	if err != nil {
		t.Fatalf("org update failed: %v", err)
	}
	if !strings.Contains(out, "Muster Hausverwaltung GmbH") {
		t.Fatalf("expected updated legal name in output, got: %s", out)
	}

	// 4. faciqor org list --json
	out, err = runCLI(t, mock, tmpConfig, "org", "list", "--json")
	if err != nil {
		t.Fatalf("org list --json failed: %v", err)
	}

	var parsed []map[string]interface{}
	if err := json.Unmarshal([]byte(out), &parsed); err != nil {
		t.Fatalf("failed to unmarshal JSON output: %v\nraw: %s", err, out)
	}
	if len(parsed) != 1 {
		t.Fatalf("expected 1 organization, got %d", len(parsed))
	}
	if parsed[0]["handle"] != "meine-hv" {
		t.Errorf("expected handle 'meine-hv', got %v", parsed[0]["handle"])
	}
	if parsed[0]["my_role"] != "MEMBERSHIP_ROLE_OWNER" {
		t.Errorf("expected my_role 'MEMBERSHIP_ROLE_OWNER', got %v", parsed[0]["my_role"])
	}
}
