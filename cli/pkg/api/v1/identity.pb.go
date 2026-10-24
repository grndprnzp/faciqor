package v1

import (
	context "context"
	grpc "google.golang.org/grpc"
)

type OrganizationFocus int32

const (
	OrganizationFocus_ORGANIZATION_FOCUS_UNSPECIFIED      OrganizationFocus = 0
	OrganizationFocus_ORGANIZATION_FOCUS_PROPERTY_OWNER   OrganizationFocus = 1
	OrganizationFocus_ORGANIZATION_FOCUS_PROPERTY_MANAGER OrganizationFocus = 2
	OrganizationFocus_ORGANIZATION_FOCUS_SERVICE_PROVIDER OrganizationFocus = 3
)

func (x OrganizationFocus) String() string {
	switch x {
	case OrganizationFocus_ORGANIZATION_FOCUS_PROPERTY_OWNER:
		return "ORGANIZATION_FOCUS_PROPERTY_OWNER"
	case OrganizationFocus_ORGANIZATION_FOCUS_PROPERTY_MANAGER:
		return "ORGANIZATION_FOCUS_PROPERTY_MANAGER"
	case OrganizationFocus_ORGANIZATION_FOCUS_SERVICE_PROVIDER:
		return "ORGANIZATION_FOCUS_SERVICE_PROVIDER"
	default:
		return "ORGANIZATION_FOCUS_UNSPECIFIED"
	}
}

type MembershipRole int32

const (
	MembershipRole_MEMBERSHIP_ROLE_UNSPECIFIED MembershipRole = 0
	MembershipRole_MEMBERSHIP_ROLE_OWNER       MembershipRole = 1
	MembershipRole_MEMBERSHIP_ROLE_MEMBER      MembershipRole = 2
	MembershipRole_MEMBERSHIP_ROLE_GUEST       MembershipRole = 3
)

func (x MembershipRole) String() string {
	switch x {
	case MembershipRole_MEMBERSHIP_ROLE_OWNER:
		return "MEMBERSHIP_ROLE_OWNER"
	case MembershipRole_MEMBERSHIP_ROLE_MEMBER:
		return "MEMBERSHIP_ROLE_MEMBER"
	case MembershipRole_MEMBERSHIP_ROLE_GUEST:
		return "MEMBERSHIP_ROLE_GUEST"
	default:
		return "MEMBERSHIP_ROLE_UNSPECIFIED"
	}
}

type GetMyProfileRequest struct{}

type UpdateMyProfileRequest struct {
	Handle string `json:"handle"`
}

type UserProfileResponse struct {
	Id            string `json:"id"`
	Email         string `json:"email"`
	Handle        string `json:"handle"`
	EmailVerified bool   `json:"email_verified"`
	InsertedAt    string `json:"inserted_at"`
}

type RequestAccountDeletionRequest struct{}

type RequestAccountDeletionResponse struct {
	PurgeScheduledAt            string   `json:"purge_scheduled_at"`
	OrphanedOrganizationHandles []string `json:"orphaned_organization_handles"`
}

type CreateOrganizationRequest struct {
	Handle        string            `json:"handle"`
	PrimaryFocus  OrganizationFocus `json:"primary_focus"`
	DisplayName   *string           `json:"display_name,omitempty"`
	LegalName     *string           `json:"legal_name,omitempty"`
	LegalForm     *string           `json:"legal_form,omitempty"`
	StreetAddress *string           `json:"street_address,omitempty"`
	PostalCode    *string           `json:"postal_code,omitempty"`
	City          *string           `json:"city,omitempty"`
	CountryCode   *string           `json:"country_code,omitempty"`
	TaxId         *string           `json:"tax_id,omitempty"`
	VatId         *string           `json:"vat_id,omitempty"`
	ContactEmail  *string           `json:"contact_email,omitempty"`
}

type UpdateOrganizationRequest struct {
	IdOrHandle    string             `json:"id_or_handle"`
	Handle        *string            `json:"handle,omitempty"`
	PrimaryFocus  *OrganizationFocus `json:"primary_focus,omitempty"`
	DisplayName   *string            `json:"display_name,omitempty"`
	LegalName     *string            `json:"legal_name,omitempty"`
	LegalForm     *string            `json:"legal_form,omitempty"`
	StreetAddress *string            `json:"street_address,omitempty"`
	PostalCode    *string            `json:"postal_code,omitempty"`
	City          *string            `json:"city,omitempty"`
	CountryCode   *string            `json:"country_code,omitempty"`
	TaxId         *string            `json:"tax_id,omitempty"`
	VatId         *string            `json:"vat_id,omitempty"`
	ContactEmail  *string            `json:"contact_email,omitempty"`
}

type GetOrganizationRequest struct {
	IdOrHandle string `json:"id_or_handle"`
}

type SoftDeleteOrganizationRequest struct {
	IdOrHandle string `json:"id_or_handle"`
}

type OrganizationResponse struct {
	Id            string            `json:"id"`
	Handle        string            `json:"handle"`
	PrimaryFocus  OrganizationFocus `json:"primary_focus"`
	MyRole        MembershipRole    `json:"my_role"`
	DisplayName   string            `json:"display_name"`
	LegalName     string            `json:"legal_name"`
	LegalForm     string            `json:"legal_form"`
	StreetAddress string            `json:"street_address"`
	PostalCode    string            `json:"postal_code"`
	City          string            `json:"city"`
	CountryCode   string            `json:"country_code"`
	TaxId         string            `json:"tax_id"`
	VatId         string            `json:"vat_id"`
	ContactEmail  string            `json:"contact_email"`
	DeletedAt     *string           `json:"deleted_at,omitempty"`
}

type ListMyOrganizationsRequest struct{}

type ListMyOrganizationsResponse struct {
	Organizations []*OrganizationResponse `json:"organizations"`
}

type IdentityServiceClient interface {
	GetMyProfile(ctx context.Context, in *GetMyProfileRequest, opts ...grpc.CallOption) (*UserProfileResponse, error)
	UpdateMyProfile(ctx context.Context, in *UpdateMyProfileRequest, opts ...grpc.CallOption) (*UserProfileResponse, error)
	RequestAccountDeletion(ctx context.Context, in *RequestAccountDeletionRequest, opts ...grpc.CallOption) (*RequestAccountDeletionResponse, error)
	CreateOrganization(ctx context.Context, in *CreateOrganizationRequest, opts ...grpc.CallOption) (*OrganizationResponse, error)
	ListMyOrganizations(ctx context.Context, in *ListMyOrganizationsRequest, opts ...grpc.CallOption) (*ListMyOrganizationsResponse, error)
	GetOrganization(ctx context.Context, in *GetOrganizationRequest, opts ...grpc.CallOption) (*OrganizationResponse, error)
	UpdateOrganization(ctx context.Context, in *UpdateOrganizationRequest, opts ...grpc.CallOption) (*OrganizationResponse, error)
	SoftDeleteOrganization(ctx context.Context, in *SoftDeleteOrganizationRequest, opts ...grpc.CallOption) (*OrganizationResponse, error)
}

type identityServiceClient struct {
	cc grpc.ClientConnInterface
}

func NewIdentityServiceClient(cc grpc.ClientConnInterface) IdentityServiceClient {
	return &identityServiceClient{cc}
}

func (c *identityServiceClient) GetMyProfile(ctx context.Context, in *GetMyProfileRequest, opts ...grpc.CallOption) (*UserProfileResponse, error) {
	out := new(UserProfileResponse)
	err := c.cc.Invoke(ctx, "/faciqor.v1.IdentityService/GetMyProfile", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *identityServiceClient) UpdateMyProfile(ctx context.Context, in *UpdateMyProfileRequest, opts ...grpc.CallOption) (*UserProfileResponse, error) {
	out := new(UserProfileResponse)
	err := c.cc.Invoke(ctx, "/faciqor.v1.IdentityService/UpdateMyProfile", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *identityServiceClient) RequestAccountDeletion(ctx context.Context, in *RequestAccountDeletionRequest, opts ...grpc.CallOption) (*RequestAccountDeletionResponse, error) {
	out := new(RequestAccountDeletionResponse)
	err := c.cc.Invoke(ctx, "/faciqor.v1.IdentityService/RequestAccountDeletion", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *identityServiceClient) CreateOrganization(ctx context.Context, in *CreateOrganizationRequest, opts ...grpc.CallOption) (*OrganizationResponse, error) {
	out := new(OrganizationResponse)
	err := c.cc.Invoke(ctx, "/faciqor.v1.IdentityService/CreateOrganization", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *identityServiceClient) ListMyOrganizations(ctx context.Context, in *ListMyOrganizationsRequest, opts ...grpc.CallOption) (*ListMyOrganizationsResponse, error) {
	out := new(ListMyOrganizationsResponse)
	err := c.cc.Invoke(ctx, "/faciqor.v1.IdentityService/ListMyOrganizations", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *identityServiceClient) GetOrganization(ctx context.Context, in *GetOrganizationRequest, opts ...grpc.CallOption) (*OrganizationResponse, error) {
	out := new(OrganizationResponse)
	err := c.cc.Invoke(ctx, "/faciqor.v1.IdentityService/GetOrganization", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *identityServiceClient) UpdateOrganization(ctx context.Context, in *UpdateOrganizationRequest, opts ...grpc.CallOption) (*OrganizationResponse, error) {
	out := new(OrganizationResponse)
	err := c.cc.Invoke(ctx, "/faciqor.v1.IdentityService/UpdateOrganization", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *identityServiceClient) SoftDeleteOrganization(ctx context.Context, in *SoftDeleteOrganizationRequest, opts ...grpc.CallOption) (*OrganizationResponse, error) {
	out := new(OrganizationResponse)
	err := c.cc.Invoke(ctx, "/faciqor.v1.IdentityService/SoftDeleteOrganization", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}
