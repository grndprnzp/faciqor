defmodule Faciqor.V1.MapProvider do
  @moduledoc false
  use Protobuf, enum: true, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :MAP_PROVIDER_UNSPECIFIED, 0
  field :MAP_PROVIDER_OPENSTREETMAP, 1
  field :MAP_PROVIDER_HERE, 2
end

defmodule Faciqor.V1.GeocodingProvider do
  @moduledoc false
  use Protobuf, enum: true, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :GEOCODING_PROVIDER_UNSPECIFIED, 0
  field :GEOCODING_PROVIDER_NOMINATIM, 1
  field :GEOCODING_PROVIDER_HERE, 2
end

defmodule Faciqor.V1.NumberRangeEntityType do
  @moduledoc false
  use Protobuf, enum: true, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :NUMBER_RANGE_ENTITY_TYPE_UNSPECIFIED, 0
  field :NUMBER_RANGE_ENTITY_TYPE_FACILITY, 1
end

defmodule Faciqor.V1.GeoCoordinate do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :latitude, 1, type: :string
  field :longitude, 2, type: :string
end

defmodule Faciqor.V1.FacilityAddressInput do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :street, 1, type: :string
  field :house_number, 2, type: :string, json_name: "houseNumber"
  field :postal_code, 3, type: :string, json_name: "postalCode"
  field :city, 4, type: :string
  field :country_code, 5, proto3_optional: true, type: :string, json_name: "countryCode"
  field :latitude, 6, proto3_optional: true, type: :string
  field :longitude, 7, proto3_optional: true, type: :string
  field :is_primary, 8, proto3_optional: true, type: :bool, json_name: "isPrimary"
end

defmodule Faciqor.V1.FacilityAddressItem do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :id, 1, type: :string
  field :street, 2, type: :string
  field :house_number, 3, type: :string, json_name: "houseNumber"
  field :postal_code, 4, type: :string, json_name: "postalCode"
  field :city, 5, type: :string
  field :country_code, 6, type: :string, json_name: "countryCode"
  field :latitude, 7, type: :string
  field :longitude, 8, type: :string
  field :is_primary, 9, type: :bool, json_name: "isPrimary"
  field :sort_order, 10, type: :int32, json_name: "sortOrder"
end

defmodule Faciqor.V1.GetGeoProviderConfigRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :org_id_or_handle, 1, type: :string, json_name: "orgIdOrHandle"
end

defmodule Faciqor.V1.UpdateGeoProviderConfigRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :org_id_or_handle, 1, type: :string, json_name: "orgIdOrHandle"
  field :map_provider, 2, proto3_optional: true, type: Faciqor.V1.MapProvider, json_name: "mapProvider", enum: true
  field :geocoding_provider, 3, proto3_optional: true, type: Faciqor.V1.GeocodingProvider, json_name: "geocodingProvider", enum: true
  field :here_api_key, 4, proto3_optional: true, type: :string, json_name: "hereApiKey"
  field :apply_to_all_owned_orgs, 5, type: :bool, json_name: "applyToAllOwnedOrgs"
end

defmodule Faciqor.V1.GeoProviderConfigResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :organization_id, 1, type: :string, json_name: "organizationId"
  field :organization_handle, 2, type: :string, json_name: "organizationHandle"
  field :map_provider, 3, type: Faciqor.V1.MapProvider, json_name: "mapProvider", enum: true
  field :geocoding_provider, 4, type: Faciqor.V1.GeocodingProvider, json_name: "geocodingProvider", enum: true
  field :has_here_api_key, 5, type: :bool, json_name: "hasHereApiKey"
  field :updated_organization_handles, 6, repeated: true, type: :string, json_name: "updatedOrganizationHandles"
end

defmodule Faciqor.V1.GetNumberRangeRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :org_id_or_handle, 1, type: :string, json_name: "orgIdOrHandle"
  field :entity_type, 2, type: Faciqor.V1.NumberRangeEntityType, json_name: "entityType", enum: true
end

defmodule Faciqor.V1.UpdateNumberRangeRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :org_id_or_handle, 1, type: :string, json_name: "orgIdOrHandle"
  field :entity_type, 2, type: Faciqor.V1.NumberRangeEntityType, json_name: "entityType", enum: true
  field :prefix, 3, proto3_optional: true, type: :string
  field :start_value, 4, proto3_optional: true, type: :int64, json_name: "startValue"
  field :current_value, 5, proto3_optional: true, type: :int64, json_name: "currentValue"
  field :step, 6, proto3_optional: true, type: :int64
  field :suffix, 7, proto3_optional: true, type: :string
end

defmodule Faciqor.V1.NumberRangeResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :id, 1, type: :string
  field :organization_id, 2, type: :string, json_name: "organizationId"
  field :entity_type, 3, type: Faciqor.V1.NumberRangeEntityType, json_name: "entityType", enum: true
  field :prefix, 4, type: :string
  field :start_value, 5, type: :int64, json_name: "startValue"
  field :current_value, 6, proto3_optional: true, type: :int64, json_name: "currentValue"
  field :step, 7, type: :int64
  field :suffix, 8, type: :string
  field :preview_next_key, 9, type: :string, json_name: "previewNextKey"
end

defmodule Faciqor.V1.ListFacilitiesRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :org_id_or_handle, 1, type: :string, json_name: "orgIdOrHandle"
  field :include_archived, 2, type: :bool, json_name: "includeArchived"
end

defmodule Faciqor.V1.ListFacilitiesResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :facilities, 1, repeated: true, type: Faciqor.V1.FacilityResponse
end

defmodule Faciqor.V1.GetFacilityRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :org_id_or_handle, 1, type: :string, json_name: "orgIdOrHandle"
  field :id_or_business_key, 2, type: :string, json_name: "idOrBusinessKey"
end

defmodule Faciqor.V1.CreateFacilityRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :org_id_or_handle, 1, type: :string, json_name: "orgIdOrHandle"
  field :addresses, 2, repeated: true, type: Faciqor.V1.FacilityAddressInput
  field :geofence_polygon, 3, repeated: true, type: Faciqor.V1.GeoCoordinate, json_name: "geofencePolygon"
  field :geofence_radius_meters, 4, proto3_optional: true, type: :int32, json_name: "geofenceRadiusMeters"
end

defmodule Faciqor.V1.UpdateFacilityRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :org_id_or_handle, 1, type: :string, json_name: "orgIdOrHandle"
  field :id_or_business_key, 2, type: :string, json_name: "idOrBusinessKey"
  field :addresses, 3, repeated: true, type: Faciqor.V1.FacilityAddressInput
  field :geofence_polygon, 4, repeated: true, type: Faciqor.V1.GeoCoordinate, json_name: "geofencePolygon"
  field :geofence_radius_meters, 5, proto3_optional: true, type: :int32, json_name: "geofenceRadiusMeters"
end

defmodule Faciqor.V1.ArchiveFacilityRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :org_id_or_handle, 1, type: :string, json_name: "orgIdOrHandle"
  field :id_or_business_key, 2, type: :string, json_name: "idOrBusinessKey"
end

defmodule Faciqor.V1.UnarchiveFacilityRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :org_id_or_handle, 1, type: :string, json_name: "orgIdOrHandle"
  field :id_or_business_key, 2, type: :string, json_name: "idOrBusinessKey"
end

defmodule Faciqor.V1.DeleteFacilityRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :org_id_or_handle, 1, type: :string, json_name: "orgIdOrHandle"
  field :id_or_business_key, 2, type: :string, json_name: "idOrBusinessKey"
end

defmodule Faciqor.V1.DeleteFacilityResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :deleted, 1, type: :bool
end

defmodule Faciqor.V1.FacilityResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :id, 1, type: :string
  field :organization_id, 2, type: :string, json_name: "organizationId"
  field :business_key, 3, type: :string, json_name: "businessKey"
  field :title, 4, type: :string
  field :addresses, 5, repeated: true, type: Faciqor.V1.FacilityAddressItem
  field :geofence_polygon, 6, repeated: true, type: Faciqor.V1.GeoCoordinate, json_name: "geofencePolygon"
  field :geofence_radius_meters, 7, type: :int32, json_name: "geofenceRadiusMeters"
  field :archived_at, 8, proto3_optional: true, type: :string, json_name: "archivedAt"
  field :inserted_at, 9, type: :string, json_name: "insertedAt"
  field :updated_at, 10, type: :string, json_name: "updatedAt"
end

defmodule Faciqor.V1.OperationsService.Service do
  @moduledoc false
  use GRPC.Service, name: "faciqor.v1.OperationsService", protoc_gen_elixir_version: "0.13.0"

  rpc :GetGeoProviderConfig, Faciqor.V1.GetGeoProviderConfigRequest, Faciqor.V1.GeoProviderConfigResponse
  rpc :UpdateGeoProviderConfig, Faciqor.V1.UpdateGeoProviderConfigRequest, Faciqor.V1.GeoProviderConfigResponse
  rpc :GetNumberRange, Faciqor.V1.GetNumberRangeRequest, Faciqor.V1.NumberRangeResponse
  rpc :UpdateNumberRange, Faciqor.V1.UpdateNumberRangeRequest, Faciqor.V1.NumberRangeResponse
  rpc :ListFacilities, Faciqor.V1.ListFacilitiesRequest, Faciqor.V1.ListFacilitiesResponse
  rpc :GetFacility, Faciqor.V1.GetFacilityRequest, Faciqor.V1.FacilityResponse
  rpc :CreateFacility, Faciqor.V1.CreateFacilityRequest, Faciqor.V1.FacilityResponse
  rpc :UpdateFacility, Faciqor.V1.UpdateFacilityRequest, Faciqor.V1.FacilityResponse
  rpc :ArchiveFacility, Faciqor.V1.ArchiveFacilityRequest, Faciqor.V1.FacilityResponse
  rpc :UnarchiveFacility, Faciqor.V1.UnarchiveFacilityRequest, Faciqor.V1.FacilityResponse
  rpc :DeleteFacility, Faciqor.V1.DeleteFacilityRequest, Faciqor.V1.DeleteFacilityResponse
end

defmodule Faciqor.V1.OperationsService.Stub do
  @moduledoc false
  use GRPC.Stub, service: Faciqor.V1.OperationsService.Service
end
