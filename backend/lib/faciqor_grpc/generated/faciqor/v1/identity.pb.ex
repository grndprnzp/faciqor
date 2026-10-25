defmodule Faciqor.V1.OrganizationFocus do
  @moduledoc false
  use Protobuf, enum: true, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :ORGANIZATION_FOCUS_UNSPECIFIED, 0
  field :ORGANIZATION_FOCUS_PROPERTY_OWNER, 1
  field :ORGANIZATION_FOCUS_PROPERTY_MANAGER, 2
  field :ORGANIZATION_FOCUS_SERVICE_PROVIDER, 3
end

defmodule Faciqor.V1.MembershipRole do
  @moduledoc false
  use Protobuf, enum: true, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :MEMBERSHIP_ROLE_UNSPECIFIED, 0
  field :MEMBERSHIP_ROLE_OWNER, 1
  field :MEMBERSHIP_ROLE_MEMBER, 2
  field :MEMBERSHIP_ROLE_GUEST, 3
end

defmodule Faciqor.V1.GetMyProfileRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3
end

defmodule Faciqor.V1.UpdateMyProfileRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :handle, 1, optional: true, type: :string
  field :display_name, 2, optional: true, type: :string, json_name: "displayName"
  field :first_name, 3, optional: true, type: :string, json_name: "firstName"
  field :last_name, 4, optional: true, type: :string, json_name: "lastName"
  field :phone, 5, optional: true, type: :string
  field :timezone, 6, optional: true, type: :string
  field :locale, 7, optional: true, type: :string
end

defmodule Faciqor.V1.UserProfileResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :id, 1, type: :string
  field :email, 2, type: :string
  field :handle, 3, type: :string
  field :email_verified, 4, type: :bool, json_name: "emailVerified"
  field :inserted_at, 5, type: :string, json_name: "insertedAt"
  field :display_name, 6, type: :string, json_name: "displayName"
  field :first_name, 7, type: :string, json_name: "firstName"
  field :last_name, 8, type: :string, json_name: "lastName"
  field :phone, 9, type: :string
  field :timezone, 10, type: :string
  field :locale, 11, type: :string
  field :pending_email, 12, optional: true, type: :string, json_name: "pendingEmail"
  field :avatar_url, 13, optional: true, type: :string, json_name: "avatarUrl"
  field :avatar_variants, 14, optional: true, type: Faciqor.V1.MediaVariants, json_name: "avatarVariants"
end

defmodule Faciqor.V1.ChangePasswordRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :current_password, 1, type: :string, json_name: "currentPassword"
  field :new_password, 2, type: :string, json_name: "newPassword"
end

defmodule Faciqor.V1.ChangePasswordResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :success, 1, type: :bool
end

defmodule Faciqor.V1.RequestEmailChangeRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :new_email, 1, type: :string, json_name: "newEmail"
end

defmodule Faciqor.V1.RequestEmailChangeResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :pending_email, 1, type: :string, json_name: "pendingEmail"
end

defmodule Faciqor.V1.ApiTokenInfo do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :id, 1, type: :string
  field :name, 2, type: :string
  field :token_prefix, 3, type: :string, json_name: "tokenPrefix"
  field :scopes, 4, type: :string
  field :inserted_at, 5, type: :string, json_name: "insertedAt"
  field :expires_at, 6, optional: true, type: :string, json_name: "expiresAt"
  field :last_used_at, 7, optional: true, type: :string, json_name: "lastUsedAt"
  field :revoked_at, 8, optional: true, type: :string, json_name: "revokedAt"
end

defmodule Faciqor.V1.ListApiTokensRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3
end

defmodule Faciqor.V1.ListApiTokensResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :tokens, 1, repeated: true, type: Faciqor.V1.ApiTokenInfo
end

defmodule Faciqor.V1.CreateApiTokenRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :name, 1, type: :string
  field :expires_in_days, 2, optional: true, type: :int32, json_name: "expiresInDays"
  field :scopes, 3, optional: true, type: :string
end

defmodule Faciqor.V1.CreateApiTokenResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :token, 1, type: Faciqor.V1.ApiTokenInfo
  field :plain_token, 2, type: :string, json_name: "plainToken"
end

defmodule Faciqor.V1.RevokeApiTokenRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :token_id, 1, type: :string, json_name: "tokenId"
end

defmodule Faciqor.V1.RevokeApiTokenResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :success, 1, type: :bool
end

defmodule Faciqor.V1.RequestAccountDeletionRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3
end

defmodule Faciqor.V1.RequestAccountDeletionResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :purge_scheduled_at, 1, type: :string, json_name: "purgeScheduledAt"
  field :orphaned_organization_handles, 2, repeated: true, type: :string, json_name: "orphanedOrganizationHandles"
end

defmodule Faciqor.V1.CreateOrganizationRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :handle, 1, type: :string
  field :primary_focus, 2, type: Faciqor.V1.OrganizationFocus, json_name: "primaryFocus", enum: true
  field :display_name, 3, proto3_optional: true, type: :string, json_name: "displayName"
  field :legal_name, 4, proto3_optional: true, type: :string, json_name: "legalName"
  field :legal_form, 5, proto3_optional: true, type: :string, json_name: "legalForm"
  field :street_address, 6, proto3_optional: true, type: :string, json_name: "streetAddress"
  field :postal_code, 7, proto3_optional: true, type: :string, json_name: "postalCode"
  field :city, 8, proto3_optional: true, type: :string
  field :country_code, 9, proto3_optional: true, type: :string, json_name: "countryCode"
  field :tax_id, 10, proto3_optional: true, type: :string, json_name: "taxId"
  field :vat_id, 11, proto3_optional: true, type: :string, json_name: "vatId"
  field :contact_email, 12, proto3_optional: true, type: :string, json_name: "contactEmail"
end

defmodule Faciqor.V1.UpdateOrganizationRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :id_or_handle, 1, type: :string, json_name: "idOrHandle"
  field :handle, 2, proto3_optional: true, type: :string
  field :primary_focus, 3, proto3_optional: true, type: Faciqor.V1.OrganizationFocus, json_name: "primaryFocus", enum: true
  field :display_name, 4, proto3_optional: true, type: :string, json_name: "displayName"
  field :legal_name, 5, proto3_optional: true, type: :string, json_name: "legalName"
  field :legal_form, 6, proto3_optional: true, type: :string, json_name: "legalForm"
  field :street_address, 7, proto3_optional: true, type: :string, json_name: "streetAddress"
  field :postal_code, 8, proto3_optional: true, type: :string, json_name: "postalCode"
  field :city, 9, proto3_optional: true, type: :string
  field :country_code, 10, proto3_optional: true, type: :string, json_name: "countryCode"
  field :tax_id, 11, proto3_optional: true, type: :string, json_name: "taxId"
  field :vat_id, 12, proto3_optional: true, type: :string, json_name: "vatId"
  field :contact_email, 13, proto3_optional: true, type: :string, json_name: "contactEmail"
end

defmodule Faciqor.V1.GetOrganizationRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :id_or_handle, 1, type: :string, json_name: "idOrHandle"
end

defmodule Faciqor.V1.SoftDeleteOrganizationRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :id_or_handle, 1, type: :string, json_name: "idOrHandle"
end

defmodule Faciqor.V1.OrganizationResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :id, 1, type: :string
  field :handle, 2, type: :string
  field :primary_focus, 3, type: Faciqor.V1.OrganizationFocus, json_name: "primaryFocus", enum: true
  field :my_role, 4, type: Faciqor.V1.MembershipRole, json_name: "myRole", enum: true
  field :display_name, 5, type: :string, json_name: "displayName"
  field :legal_name, 6, type: :string, json_name: "legalName"
  field :legal_form, 7, type: :string, json_name: "legalForm"
  field :street_address, 8, type: :string, json_name: "streetAddress"
  field :postal_code, 9, type: :string, json_name: "postalCode"
  field :city, 10, type: :string
  field :country_code, 11, type: :string, json_name: "countryCode"
  field :tax_id, 12, type: :string, json_name: "taxId"
  field :vat_id, 13, type: :string, json_name: "vatId"
  field :contact_email, 14, type: :string, json_name: "contactEmail"
  field :deleted_at, 15, proto3_optional: true, type: :string, json_name: "deletedAt"
  field :logo_url, 16, proto3_optional: true, type: :string, json_name: "logoUrl"
  field :logo_variants, 17, proto3_optional: true, type: Faciqor.V1.MediaVariants, json_name: "logoVariants"
end

defmodule Faciqor.V1.ListMyOrganizationsRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3
end

defmodule Faciqor.V1.ListMyOrganizationsResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :organizations, 1, repeated: true, type: Faciqor.V1.OrganizationResponse
end

defmodule Faciqor.V1.IdentityService.Service do
  @moduledoc false
  use GRPC.Service, name: "faciqor.v1.IdentityService", protoc_gen_elixir_version: "0.13.0"

  rpc :GetMyProfile, Faciqor.V1.GetMyProfileRequest, Faciqor.V1.UserProfileResponse
  rpc :UpdateMyProfile, Faciqor.V1.UpdateMyProfileRequest, Faciqor.V1.UserProfileResponse
  rpc :ChangePassword, Faciqor.V1.ChangePasswordRequest, Faciqor.V1.ChangePasswordResponse
  rpc :RequestEmailChange, Faciqor.V1.RequestEmailChangeRequest, Faciqor.V1.RequestEmailChangeResponse
  rpc :RequestAccountDeletion, Faciqor.V1.RequestAccountDeletionRequest, Faciqor.V1.RequestAccountDeletionResponse
  rpc :ListApiTokens, Faciqor.V1.ListApiTokensRequest, Faciqor.V1.ListApiTokensResponse
  rpc :CreateApiToken, Faciqor.V1.CreateApiTokenRequest, Faciqor.V1.CreateApiTokenResponse
  rpc :RevokeApiToken, Faciqor.V1.RevokeApiTokenRequest, Faciqor.V1.RevokeApiTokenResponse
  rpc :CreateOrganization, Faciqor.V1.CreateOrganizationRequest, Faciqor.V1.OrganizationResponse
  rpc :ListMyOrganizations, Faciqor.V1.ListMyOrganizationsRequest, Faciqor.V1.ListMyOrganizationsResponse
  rpc :GetOrganization, Faciqor.V1.GetOrganizationRequest, Faciqor.V1.OrganizationResponse
  rpc :UpdateOrganization, Faciqor.V1.UpdateOrganizationRequest, Faciqor.V1.OrganizationResponse
  rpc :SoftDeleteOrganization, Faciqor.V1.SoftDeleteOrganizationRequest, Faciqor.V1.OrganizationResponse
  rpc :GetAvatarUploadTicket, Faciqor.V1.GetAvatarUploadTicketRequest, Faciqor.V1.UploadTicketResponse
  rpc :SetAvatar, Faciqor.V1.SetAvatarRequest, Faciqor.V1.UserProfileResponse
  rpc :RemoveAvatar, Faciqor.V1.RemoveAvatarRequest, Faciqor.V1.UserProfileResponse
  rpc :GetOrganizationLogoUploadTicket, Faciqor.V1.GetOrganizationLogoUploadTicketRequest, Faciqor.V1.UploadTicketResponse
  rpc :SetOrganizationLogo, Faciqor.V1.SetOrganizationLogoRequest, Faciqor.V1.OrganizationResponse
  rpc :RemoveOrganizationLogo, Faciqor.V1.RemoveOrganizationLogoRequest, Faciqor.V1.OrganizationResponse
end

defmodule Faciqor.V1.MediaVariants do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :size_64, 1, proto3_optional: true, type: :string, json_name: "size64"
  field :size_128, 2, proto3_optional: true, type: :string, json_name: "size128"
  field :size_256, 3, proto3_optional: true, type: :string, json_name: "size256"
  field :size_512, 4, proto3_optional: true, type: :string, json_name: "size512"
end

defmodule Faciqor.V1.GetAvatarUploadTicketRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :content_type, 1, type: :string, json_name: "contentType"
  field :byte_size, 2, type: :int64, json_name: "byteSize"
  field :sha256, 3, type: :string
end

defmodule Faciqor.V1.GetOrganizationLogoUploadTicketRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :id_or_handle, 1, type: :string, json_name: "idOrHandle"
  field :content_type, 2, type: :string, json_name: "contentType"
  field :byte_size, 3, type: :int64, json_name: "byteSize"
  field :sha256, 4, type: :string
end

defmodule Faciqor.V1.UploadTicketResponse.HeadersEntry do
  @moduledoc false
  use Protobuf, map: true, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Faciqor.V1.UploadTicketResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :blob_id, 1, type: :string, json_name: "blobId"
  field :upload_url, 2, type: :string, json_name: "uploadUrl"
  field :storage_key, 3, type: :string, json_name: "storageKey"
  field :headers, 4, repeated: true, type: Faciqor.V1.UploadTicketResponse.HeadersEntry, map: true
end

defmodule Faciqor.V1.SetAvatarRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :blob_id, 1, type: :string, json_name: "blobId"
end

defmodule Faciqor.V1.RemoveAvatarRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3
end

defmodule Faciqor.V1.SetOrganizationLogoRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :id_or_handle, 1, type: :string, json_name: "idOrHandle"
  field :blob_id, 2, type: :string, json_name: "blobId"
end

defmodule Faciqor.V1.RemoveOrganizationLogoRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :id_or_handle, 1, type: :string, json_name: "idOrHandle"
end

defmodule Faciqor.V1.IdentityService.Stub do
  @moduledoc false
  use GRPC.Stub, service: Faciqor.V1.IdentityService.Service
end
