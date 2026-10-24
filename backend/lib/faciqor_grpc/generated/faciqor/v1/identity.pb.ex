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

  field :handle, 1, type: :string
end

defmodule Faciqor.V1.UserProfileResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :id, 1, type: :string
  field :email, 2, type: :string
  field :handle, 3, type: :string
  field :email_verified, 4, type: :bool, json_name: "emailVerified"
  field :inserted_at, 5, type: :string, json_name: "insertedAt"
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
  rpc :RequestAccountDeletion, Faciqor.V1.RequestAccountDeletionRequest, Faciqor.V1.RequestAccountDeletionResponse
  rpc :CreateOrganization, Faciqor.V1.CreateOrganizationRequest, Faciqor.V1.OrganizationResponse
  rpc :ListMyOrganizations, Faciqor.V1.ListMyOrganizationsRequest, Faciqor.V1.ListMyOrganizationsResponse
  rpc :GetOrganization, Faciqor.V1.GetOrganizationRequest, Faciqor.V1.OrganizationResponse
  rpc :UpdateOrganization, Faciqor.V1.UpdateOrganizationRequest, Faciqor.V1.OrganizationResponse
  rpc :SoftDeleteOrganization, Faciqor.V1.SoftDeleteOrganizationRequest, Faciqor.V1.OrganizationResponse
end

defmodule Faciqor.V1.IdentityService.Stub do
  @moduledoc false
  use GRPC.Stub, service: Faciqor.V1.IdentityService.Service
end
