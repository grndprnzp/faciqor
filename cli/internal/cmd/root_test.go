package cmd_test

import (
	"bytes"
	"context"
	"encoding/json"
	"image"
	"image/color"
	"image/png"
	"net/http"
	"net/http/httptest"
	"os"
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
	uploadURL  string
	profile    *v1.UserProfileResponse
	orgs       map[string]*v1.OrganizationResponse
	facilities map[string]*v1.FacilityResponse
	nr         *v1.NumberRangeResponse
	geoCfg     *v1.GeoProviderConfigResponse
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
		orgs:       make(map[string]*v1.OrganizationResponse),
		facilities: make(map[string]*v1.FacilityResponse),
		nr: &v1.NumberRangeResponse{
			Id:             "nr-uuid-1",
			OrganizationId: "org-uuid-1",
			EntityType:     v1.NumberRangeEntityType_NUMBER_RANGE_ENTITY_TYPE_FACILITY,
			Prefix:         "OBJ-",
			StartValue:     1000,
			Step:           1,
			Suffix:         "",
			PreviewNextKey: "OBJ-1000",
		},
		geoCfg: &v1.GeoProviderConfigResponse{
			OrganizationId:             "org-uuid-1",
			OrganizationHandle:         "meine-hv",
			MapProvider:                v1.MapProvider_MAP_PROVIDER_OPENSTREETMAP,
			GeocodingProvider:          v1.GeocodingProvider_GEOCODING_PROVIDER_NOMINATIM,
			HasHereApiKey:              false,
			UpdatedOrganizationHandles: []string{"meine-hv"},
		},
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
	if in.Handle != nil {
		m.profile.Handle = *in.Handle
	}
	if in.DisplayName != nil {
		m.profile.DisplayName = *in.DisplayName
	}
	if in.FirstName != nil {
		m.profile.FirstName = *in.FirstName
	}
	if in.LastName != nil {
		m.profile.LastName = *in.LastName
	}
	if in.Phone != nil {
		m.profile.Phone = *in.Phone
	}
	if in.Timezone != nil {
		m.profile.Timezone = *in.Timezone
	}
	if in.Locale != nil {
		m.profile.Locale = *in.Locale
	}
	return m.profile, nil
}

func (m *mockIdentityClient) ChangePassword(ctx context.Context, in *v1.ChangePasswordRequest, opts ...grpc.CallOption) (*v1.ChangePasswordResponse, error) {
	if err := m.checkGate(); err != nil {
		return nil, err
	}
	return &v1.ChangePasswordResponse{Success: true}, nil
}

func (m *mockIdentityClient) RequestEmailChange(ctx context.Context, in *v1.RequestEmailChangeRequest, opts ...grpc.CallOption) (*v1.RequestEmailChangeResponse, error) {
	if err := m.checkGate(); err != nil {
		return nil, err
	}
	m.profile.PendingEmail = &in.NewEmail
	return &v1.RequestEmailChangeResponse{PendingEmail: in.NewEmail}, nil
}

func (m *mockIdentityClient) ListApiTokens(ctx context.Context, in *v1.ListApiTokensRequest, opts ...grpc.CallOption) (*v1.ListApiTokensResponse, error) {
	if err := m.checkGate(); err != nil {
		return nil, err
	}
	tokens := []*v1.ApiTokenInfo{
		{
			Id:          "token-uuid-1",
			Name:        "Laptop CLI",
			TokenPrefix: "fq_pat_test",
			Scopes:      "all",
			InsertedAt:  "2026-10-25T08:00:00Z",
		},
	}
	return &v1.ListApiTokensResponse{Tokens: tokens}, nil
}

func (m *mockIdentityClient) CreateApiToken(ctx context.Context, in *v1.CreateApiTokenRequest, opts ...grpc.CallOption) (*v1.CreateApiTokenResponse, error) {
	if err := m.checkGate(); err != nil {
		return nil, err
	}
	tok := &v1.ApiTokenInfo{
		Id:          "token-uuid-created",
		Name:        in.Name,
		TokenPrefix: "fq_pat_new1",
		Scopes:      "all",
		InsertedAt:  "2026-10-25T08:00:00Z",
	}
	return &v1.CreateApiTokenResponse{
		Token:      tok,
		PlainToken: "fq_pat_new123456789",
	}, nil
}

func (m *mockIdentityClient) RevokeApiToken(ctx context.Context, in *v1.RevokeApiTokenRequest, opts ...grpc.CallOption) (*v1.RevokeApiTokenResponse, error) {
	if err := m.checkGate(); err != nil {
		return nil, err
	}
	return &v1.RevokeApiTokenResponse{Success: true}, nil
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

func (m *mockIdentityClient) GetAvatarUploadTicket(ctx context.Context, in *v1.GetAvatarUploadTicketRequest, opts ...grpc.CallOption) (*v1.UploadTicketResponse, error) {
	if err := m.checkGate(); err != nil {
		return nil, err
	}
	uploadURL := "http://localhost:8333/faciqor-public/avatars/user-1/original.png"
	if m.uploadURL != "" {
		uploadURL = m.uploadURL
	}
	return &v1.UploadTicketResponse{
		BlobId:     "blob-avatar-123",
		UploadUrl:  uploadURL,
		StorageKey: "avatars/user-1/original.png",
	}, nil
}

func (m *mockIdentityClient) SetAvatar(ctx context.Context, in *v1.SetAvatarRequest, opts ...grpc.CallOption) (*v1.UserProfileResponse, error) {
	if err := m.checkGate(); err != nil {
		return nil, err
	}
	avatarURL := "http://localhost:8333/faciqor-public/avatars/user-1/512.webp"
	m.profile.AvatarUrl = &avatarURL
	return m.profile, nil
}

func (m *mockIdentityClient) RemoveAvatar(ctx context.Context, in *v1.RemoveAvatarRequest, opts ...grpc.CallOption) (*v1.UserProfileResponse, error) {
	if err := m.checkGate(); err != nil {
		return nil, err
	}
	m.profile.AvatarUrl = nil
	m.profile.AvatarVariants = nil
	return m.profile, nil
}

func (m *mockIdentityClient) GetOrganizationLogoUploadTicket(ctx context.Context, in *v1.GetOrganizationLogoUploadTicketRequest, opts ...grpc.CallOption) (*v1.UploadTicketResponse, error) {
	if err := m.checkGate(); err != nil {
		return nil, err
	}
	uploadURL := "http://localhost:8333/faciqor-public/logos/org-1/original.png"
	if m.uploadURL != "" {
		uploadURL = m.uploadURL
	}
	return &v1.UploadTicketResponse{
		BlobId:     "blob-logo-123",
		UploadUrl:  uploadURL,
		StorageKey: "logos/org-1/original.png",
	}, nil
}

func (m *mockIdentityClient) SetOrganizationLogo(ctx context.Context, in *v1.SetOrganizationLogoRequest, opts ...grpc.CallOption) (*v1.OrganizationResponse, error) {
	if err := m.checkGate(); err != nil {
		return nil, err
	}
	org, ok := m.orgs[in.IdOrHandle]
	if !ok {
		return nil, status.Error(codes.NotFound, "organization not found")
	}
	logoURL := "http://localhost:8333/faciqor-public/logos/org-1/512.webp"
	org.LogoUrl = &logoURL
	return org, nil
}

func (m *mockIdentityClient) RemoveOrganizationLogo(ctx context.Context, in *v1.RemoveOrganizationLogoRequest, opts ...grpc.CallOption) (*v1.OrganizationResponse, error) {
	if err := m.checkGate(); err != nil {
		return nil, err
	}
	org, ok := m.orgs[in.IdOrHandle]
	if !ok {
		return nil, status.Error(codes.NotFound, "organization not found")
	}
	org.LogoUrl = nil
	org.LogoVariants = nil
	return org, nil
}

// --- OperationsServiceClient mock implementation ---

func (m *mockIdentityClient) GetGeoProviderConfig(ctx context.Context, in *v1.GetGeoProviderConfigRequest, opts ...grpc.CallOption) (*v1.GeoProviderConfigResponse, error) {
	if err := m.checkGate(); err != nil {
		return nil, err
	}
	return m.geoCfg, nil
}

func (m *mockIdentityClient) UpdateGeoProviderConfig(ctx context.Context, in *v1.UpdateGeoProviderConfigRequest, opts ...grpc.CallOption) (*v1.GeoProviderConfigResponse, error) {
	if err := m.checkGate(); err != nil {
		return nil, err
	}
	if in.MapProvider != nil {
		m.geoCfg.MapProvider = *in.MapProvider
	}
	if in.GeocodingProvider != nil {
		m.geoCfg.GeocodingProvider = *in.GeocodingProvider
	}
	if in.HereApiKey != nil && *in.HereApiKey != "" {
		m.geoCfg.HasHereApiKey = true
	}
	return m.geoCfg, nil
}

func (m *mockIdentityClient) GetNumberRange(ctx context.Context, in *v1.GetNumberRangeRequest, opts ...grpc.CallOption) (*v1.NumberRangeResponse, error) {
	if err := m.checkGate(); err != nil {
		return nil, err
	}
	return m.nr, nil
}

func (m *mockIdentityClient) UpdateNumberRange(ctx context.Context, in *v1.UpdateNumberRangeRequest, opts ...grpc.CallOption) (*v1.NumberRangeResponse, error) {
	if err := m.checkGate(); err != nil {
		return nil, err
	}
	if in.Prefix != nil {
		m.nr.Prefix = *in.Prefix
	}
	if in.StartValue != nil {
		m.nr.StartValue = *in.StartValue
	}
	if in.Step != nil {
		m.nr.Step = *in.Step
	}
	if in.Suffix != nil {
		m.nr.Suffix = *in.Suffix
	}
	m.nr.PreviewNextKey = "OG-2000-A"
	return m.nr, nil
}

func (m *mockIdentityClient) ListFacilities(ctx context.Context, in *v1.ListFacilitiesRequest, opts ...grpc.CallOption) (*v1.ListFacilitiesResponse, error) {
	if err := m.checkGate(); err != nil {
		return nil, err
	}
	list := make([]*v1.FacilityResponse, 0, len(m.facilities))
	for _, f := range m.facilities {
		list = append(list, f)
	}
	return &v1.ListFacilitiesResponse{Facilities: list}, nil
}

func (m *mockIdentityClient) GetFacility(ctx context.Context, in *v1.GetFacilityRequest, opts ...grpc.CallOption) (*v1.FacilityResponse, error) {
	if err := m.checkGate(); err != nil {
		return nil, err
	}
	f, ok := m.facilities[in.IdOrBusinessKey]
	if !ok {
		return nil, status.Error(codes.NotFound, "facility not found")
	}
	return f, nil
}

func (m *mockIdentityClient) CreateFacility(ctx context.Context, in *v1.CreateFacilityRequest, opts ...grpc.CallOption) (*v1.FacilityResponse, error) {
	if err := m.checkGate(); err != nil {
		return nil, err
	}
	addrs := make([]*v1.FacilityAddressItem, 0, len(in.Addresses))
	for i, a := range in.Addresses {
		addrs = append(addrs, &v1.FacilityAddressItem{
			Id:          "addr-uuid",
			Street:      a.Street,
			HouseNumber: a.HouseNumber,
			PostalCode:  a.PostalCode,
			City:        a.City,
			CountryCode: "DE",
			Latitude:    "52.5200000",
			Longitude:   "13.4050000",
			IsPrimary:   i == 0,
			SortOrder:   int32(i),
		})
	}
	fac := &v1.FacilityResponse{
		Id:                   "fac-uuid-1",
		OrganizationId:       "org-uuid-1",
		BusinessKey:          "OBJ-1000",
		Title:                "Hauptstraße 10-13",
		Addresses:            addrs,
		GeofenceRadiusMeters: 50,
		InsertedAt:           "2026-10-25T10:00:00Z",
		UpdatedAt:            "2026-10-25T10:00:00Z",
	}
	m.facilities[fac.BusinessKey] = fac
	return fac, nil
}

func (m *mockIdentityClient) UpdateFacility(ctx context.Context, in *v1.UpdateFacilityRequest, opts ...grpc.CallOption) (*v1.FacilityResponse, error) {
	if err := m.checkGate(); err != nil {
		return nil, err
	}
	fac, ok := m.facilities[in.IdOrBusinessKey]
	if !ok {
		return nil, status.Error(codes.NotFound, "facility not found")
	}
	if in.GeofenceRadiusMeters != nil {
		fac.GeofenceRadiusMeters = *in.GeofenceRadiusMeters
	}
	return fac, nil
}

func (m *mockIdentityClient) ArchiveFacility(ctx context.Context, in *v1.ArchiveFacilityRequest, opts ...grpc.CallOption) (*v1.FacilityResponse, error) {
	if err := m.checkGate(); err != nil {
		return nil, err
	}
	fac, ok := m.facilities[in.IdOrBusinessKey]
	if !ok {
		return nil, status.Error(codes.NotFound, "facility not found")
	}
	now := "2026-10-25T11:00:00Z"
	fac.ArchivedAt = &now
	return fac, nil
}

func (m *mockIdentityClient) UnarchiveFacility(ctx context.Context, in *v1.UnarchiveFacilityRequest, opts ...grpc.CallOption) (*v1.FacilityResponse, error) {
	if err := m.checkGate(); err != nil {
		return nil, err
	}
	fac, ok := m.facilities[in.IdOrBusinessKey]
	if !ok {
		return nil, status.Error(codes.NotFound, "facility not found")
	}
	fac.ArchivedAt = nil
	return fac, nil
}

func (m *mockIdentityClient) DeleteFacility(ctx context.Context, in *v1.DeleteFacilityRequest, opts ...grpc.CallOption) (*v1.DeleteFacilityResponse, error) {
	if err := m.checkGate(); err != nil {
		return nil, err
	}
	delete(m.facilities, in.IdOrBusinessKey)
	return &v1.DeleteFacilityResponse{Deleted: true}, nil
}

func runCLI(t *testing.T, mock *mockIdentityClient, configPath string, args ...string) (string, error) {
	t.Helper()
	factory := func(endpoint, token string) (v1.IdentityServiceClient, func() error, error) {
		return mock, func() error { return nil }, nil
	}
	opsFactory := func(endpoint, token string) (v1.OperationsServiceClient, func() error, error) {
		return mock, func() error { return nil }, nil
	}
	opts := &cmd.Options{
		ConfigPath:              configPath,
		ClientFactory:           client.Factory(factory),
		OperationsClientFactory: client.OperationsFactory(opsFactory),
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

func TestProfileAndTokenCommands(t *testing.T) {
	mock := newMockClient(false)
	tmpConfig := filepath.Join(t.TempDir(), "config.yaml")

	// 1. faciqor profile update with new fields
	out, err := runCLI(t, mock, tmpConfig, "profile", "update",
		"--handle", "@max_dev",
		"--display-name", "Max Mustermann",
		"--first-name", "Max",
		"--last-name", "Mustermann",
		"--phone", "+49 170 1234567",
		"--timezone", "Europe/Berlin",
		"--locale", "de",
	)
	if err != nil {
		t.Fatalf("profile update failed: %v", err)
	}
	if !strings.Contains(out, "Max Mustermann") {
		t.Errorf("expected updated display name in output, got: %s", out)
	}
	if mock.profile.Handle != "max_dev" {
		t.Errorf("expected normalized handle 'max_dev', got: %s", mock.profile.Handle)
	}

	// 2. faciqor profile password
	out, err = runCLI(t, mock, tmpConfig, "profile", "password", "--current-password", "oldpass123", "--new-password", "newsecret123")
	if err != nil {
		t.Fatalf("profile password failed: %v", err)
	}
	if !strings.Contains(out, "erfolgreich geändert") {
		t.Errorf("expected success message in output, got: %s", out)
	}

	// 3. faciqor profile email-change
	out, err = runCLI(t, mock, tmpConfig, "profile", "email-change", "--email", "new@example.com")
	if err != nil {
		t.Fatalf("profile email-change failed: %v", err)
	}
	if !strings.Contains(out, "new@example.com") {
		t.Errorf("expected pending email in output, got: %s", out)
	}

	// 4. faciqor auth token list
	out, err = runCLI(t, mock, tmpConfig, "auth", "token", "list")
	if err != nil {
		t.Fatalf("auth token list failed: %v", err)
	}
	if !strings.Contains(out, "Laptop CLI") {
		t.Errorf("expected 'Laptop CLI' in token list, got: %s", out)
	}

	// 5. faciqor auth token create
	out, err = runCLI(t, mock, tmpConfig, "auth", "token", "create", "--name", "New Workstation", "--expires-in-days", "90")
	if err != nil {
		t.Fatalf("auth token create failed: %v", err)
	}
	if !strings.Contains(out, "fq_pat_new123456789") {
		t.Errorf("expected plain token in output, got: %s", out)
	}

	// 6. faciqor auth token revoke
	out, err = runCLI(t, mock, tmpConfig, "auth", "token", "revoke", "--id", "token-uuid-1")
	if err != nil {
		t.Fatalf("auth token revoke failed: %v", err)
	}
	if !strings.Contains(out, "erfolgreich widerrufen") {
		t.Errorf("expected success message in output, got: %s", out)
	}
}

func createTestPNG(t *testing.T, w, h int) string {
	t.Helper()
	img := image.NewRGBA(image.Rect(0, 0, w, h))
	for y := 0; y < h; y++ {
		for x := 0; x < w; x++ {
			img.Set(x, y, color.RGBA{R: uint8(x % 256), G: uint8(y % 256), B: 128, A: 255})
		}
	}
	f, err := os.CreateTemp(t.TempDir(), "test-*.png")
	if err != nil {
		t.Fatalf("failed to create temp file: %v", err)
	}
	defer f.Close()
	if err := png.Encode(f, img); err != nil {
		t.Fatalf("failed to encode test png: %v", err)
	}
	return f.Name()
}

func TestAvatarAndLogoCommands(t *testing.T) {
	mock := newMockClient(false)
	tmpConfig := filepath.Join(t.TempDir(), "config.yaml")

	// Start test HTTP server to mock S3 upload
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPut {
			w.WriteHeader(http.StatusMethodNotAllowed)
			return
		}
		w.WriteHeader(http.StatusOK)
	}))
	defer srv.Close()

	mock.uploadURL = srv.URL + "/upload"

	validImage := createTestPNG(t, 512, 512)
	smallImage := createTestPNG(t, 256, 256)
	nonSquareImage := createTestPNG(t, 512, 600)

	// 1. Validation failure: small image
	_, err := runCLI(t, mock, tmpConfig, "profile", "avatar", "set", smallImage)
	if err == nil || !strings.Contains(err.Error(), "at least 512x512px") {
		t.Fatalf("expected 512px error, got: %v", err)
	}

	// 2. Validation failure: non-square image
	_, err = runCLI(t, mock, tmpConfig, "profile", "avatar", "set", nonSquareImage)
	if err == nil || !strings.Contains(err.Error(), "image must be square") {
		t.Fatalf("expected square error, got: %v", err)
	}

	// 3. Avatar set success
	out, err := runCLI(t, mock, tmpConfig, "profile", "avatar", "set", validImage)
	if err != nil {
		t.Fatalf("avatar set failed: %v", err)
	}
	if !strings.Contains(out, "Avatar erfolgreich aktualisiert") {
		t.Errorf("expected success message in output, got: %s", out)
	}
	if mock.profile.AvatarUrl == nil {
		t.Errorf("expected mock profile avatar URL to be set")
	}

	// 4. Avatar remove success
	out, err = runCLI(t, mock, tmpConfig, "profile", "avatar", "remove")
	if err != nil {
		t.Fatalf("avatar remove failed: %v", err)
	}
	if !strings.Contains(out, "Avatar erfolgreich entfernt") {
		t.Errorf("expected removal message in output, got: %s", out)
	}
	if mock.profile.AvatarUrl != nil {
		t.Errorf("expected mock profile avatar URL to be nil")
	}

	// 5. Create an organization to test logo
	_, err = runCLI(t, mock, tmpConfig, "org", "create", "--handle", "logo-test-org", "--focus", "manager")
	if err != nil {
		t.Fatalf("org create failed: %v", err)
	}

	// 6. Organization logo set success
	out, err = runCLI(t, mock, tmpConfig, "org", "logo", "set", "logo-test-org", validImage)
	if err != nil {
		t.Fatalf("org logo set failed: %v", err)
	}
	if !strings.Contains(out, "Firmenlogo erfolgreich aktualisiert") {
		t.Errorf("expected logo success message in output, got: %s", out)
	}
	if mock.orgs["logo-test-org"].LogoUrl == nil {
		t.Errorf("expected org logo URL to be set")
	}

	// 7. Organization logo remove success
	out, err = runCLI(t, mock, tmpConfig, "org", "logo", "remove", "logo-test-org")
	if err != nil {
		t.Fatalf("org logo remove failed: %v", err)
	}
	if !strings.Contains(out, "Firmenlogo erfolgreich entfernt") {
		t.Errorf("expected logo removal message in output, got: %s", out)
	}
	if mock.orgs["logo-test-org"].LogoUrl != nil {
		t.Errorf("expected org logo URL to be nil")
	}
}

func TestFacilityNumberRangeAndGeoProviderCommands(t *testing.T) {
	mock := newMockClient(false)
	tmpConfig := filepath.Join(t.TempDir(), "config.yaml")

	// 1. Number range show & update
	out, err := runCLI(t, mock, tmpConfig, "org", "number-range", "show", "meine-hv")
	if err != nil {
		t.Fatalf("number-range show failed: %v", err)
	}
	if !strings.Contains(out, "OBJ-1000") {
		t.Errorf("expected OBJ-1000 in output, got: %s", out)
	}

	out, err = runCLI(t, mock, tmpConfig, "org", "number-range", "update", "meine-hv", "--prefix", "OG-", "--start", "2000", "--step", "5", "--suffix", "-A")
	if err != nil {
		t.Fatalf("number-range update failed: %v", err)
	}
	if !strings.Contains(out, "OG-2000-A") {
		t.Errorf("expected OG-2000-A in output, got: %s", out)
	}

	// 2. Geo provider show & update
	out, err = runCLI(t, mock, tmpConfig, "org", "geo-provider", "update", "meine-hv", "--map-provider", "here", "--geocoding-provider", "here", "--here-api-key", "secret-123", "--apply-all-owned")
	if err != nil {
		t.Fatalf("geo-provider update failed: %v", err)
	}
	if !strings.Contains(out, "MAP_PROVIDER_HERE") {
		t.Errorf("expected MAP_PROVIDER_HERE in output, got: %s", out)
	}

	// 3. Facility create with address range
	out, err = runCLI(t, mock, tmpConfig, "facility", "create", "--org", "meine-hv", "--address", "Hauptstraße 10-13, 10115 Berlin", "--radius", "50")
	if err != nil {
		t.Fatalf("facility create failed: %v", err)
	}
	if !strings.Contains(out, "OBJ-1000") || !strings.Contains(out, "Hauptstraße 10-13") {
		t.Errorf("expected OBJ-1000 and Hauptstraße 10-13 in output, got: %s", out)
	}

	// 4. Facility list --json
	out, err = runCLI(t, mock, tmpConfig, "facility", "list", "--org", "meine-hv", "--json")
	if err != nil {
		t.Fatalf("facility list --json failed: %v", err)
	}
	if !strings.Contains(out, "Hauptstraße 10-13") {
		t.Errorf("expected facility in JSON list, got: %s", out)
	}

	// 5. Facility archive, unarchive & delete
	_, err = runCLI(t, mock, tmpConfig, "facility", "archive", "OBJ-1000", "--org", "meine-hv")
	if err != nil {
		t.Fatalf("facility archive failed: %v", err)
	}
	_, err = runCLI(t, mock, tmpConfig, "facility", "unarchive", "OBJ-1000", "--org", "meine-hv")
	if err != nil {
		t.Fatalf("facility unarchive failed: %v", err)
	}
	out, err = runCLI(t, mock, tmpConfig, "facility", "delete", "OBJ-1000", "--org", "meine-hv", "--yes")
	if err != nil {
		t.Fatalf("facility delete failed: %v", err)
	}
	if !strings.Contains(out, "Objekt erfolgreich gelöscht") {
		t.Errorf("expected deletion confirmation, got: %s", out)
	}
}
