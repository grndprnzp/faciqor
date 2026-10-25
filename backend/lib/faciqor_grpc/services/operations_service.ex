defmodule FaciqorGrpc.Services.OperationsService do
  @moduledoc """
  gRPC-Service-Adapter für Objekte (`Facility`), Nummernkreise (`NumberRange`)
  und Geo-Provider-Einstellungen gemäß REQ-M2-FACILITIES § 5.1.
  """
  use GRPC.Server, service: Faciqor.V1.OperationsService.Service

  alias Faciqor.Accounts
  alias Faciqor.Operations
  alias Faciqor.Operations.NumberRange
  alias Faciqor.V1
  alias FaciqorGrpc.Services.IdentityService

  # --- Geo Provider Configuration ---

  def get_geo_provider_config(%V1.GetGeoProviderConfigRequest{org_id_or_handle: org_ref}, _stream) do
    actor = current_actor!()

    case Accounts.get_organization_by_id_or_handle(org_ref, actor: actor) do
      {:ok, org} ->
        to_geo_config_response(org, [to_string(org.handle)])

      {:error, err} ->
        raise_ash_error!(err)
    end
  end

  def update_geo_provider_config(%V1.UpdateGeoProviderConfigRequest{} = req, _stream) do
    actor = current_actor!()

    with {:ok, org} <- Accounts.get_organization_by_id_or_handle(req.org_id_or_handle, actor: actor) do
      attrs =
        %{}
        |> maybe_put_map_provider(req.map_provider)
        |> maybe_put_geocoding_provider(req.geocoding_provider)
        |> maybe_put_api_key(req.here_api_key)

      case Accounts.update_geo_provider_config(
             org,
             attrs,
             actor: actor,
             apply_to_all_owned_orgs: req.apply_to_all_owned_orgs == true
           ) do
        {:ok, updated_org, handles} ->
          to_geo_config_response(updated_org, handles)

        {:error, err} ->
          raise_ash_error!(err)
      end
    else
      {:error, err} -> raise_ash_error!(err)
    end
  end

  # --- Number Ranges ---

  def get_number_range(%V1.GetNumberRangeRequest{org_id_or_handle: org_ref} = req, _stream) do
    actor = current_actor!()
    entity_type = from_proto_entity_type(req.entity_type)

    with {:ok, org} <- Accounts.get_organization_by_id_or_handle(org_ref, actor: actor),
         {:ok, nr} <- Operations.get_number_range(entity_type, actor: actor, tenant: org.id) do
      to_number_range_response(nr)
    else
      {:error, err} -> raise_ash_error!(err)
    end
  end

  def update_number_range(%V1.UpdateNumberRangeRequest{org_id_or_handle: org_ref} = req, _stream) do
    actor = current_actor!()
    entity_type = from_proto_entity_type(req.entity_type)

    with {:ok, org} <- Accounts.get_organization_by_id_or_handle(org_ref, actor: actor) do
      attrs =
        %{entity_type: entity_type}
        |> maybe_put_string(:prefix, req.prefix)
        |> maybe_put_int(:start_value, req.start_value)
        |> maybe_put_int(:current_value, req.current_value)
        |> maybe_put_int(:step, req.step)
        |> maybe_put_string(:suffix, req.suffix)

      case Operations.update_number_range(attrs, actor: actor, tenant: org.id) do
        {:ok, updated_nr} -> to_number_range_response(updated_nr)
        {:error, err} -> raise_ash_error!(err)
      end
    else
      {:error, err} -> raise_ash_error!(err)
    end
  end

  # --- Facilities CRUD ---

  def list_facilities(%V1.ListFacilitiesRequest{org_id_or_handle: org_ref, include_archived: inc_arch}, _stream) do
    actor = current_actor!()

    with {:ok, org} <- Accounts.get_organization_by_id_or_handle(org_ref, actor: actor),
         {:ok, facilities} <-
           Operations.list_facilities(
             actor: actor,
             tenant: org.id,
             include_archived?: inc_arch == true
           ) do
      %V1.ListFacilitiesResponse{
        facilities: Enum.map(facilities, &to_facility_response/1)
      }
    else
      {:error, err} -> raise_ash_error!(err)
    end
  end

  def get_facility(%V1.GetFacilityRequest{org_id_or_handle: org_ref, id_or_business_key: id_or_key}, _stream) do
    actor = current_actor!()

    with {:ok, org} <- Accounts.get_organization_by_id_or_handle(org_ref, actor: actor),
         {:ok, facility} <- Operations.get_facility_by_id_or_key(id_or_key, actor: actor, tenant: org.id) do
      to_facility_response(facility)
    else
      {:error, err} -> raise_ash_error!(err)
    end
  end

  def create_facility(%V1.CreateFacilityRequest{org_id_or_handle: org_ref} = req, _stream) do
    actor = current_actor!()

    with {:ok, org} <- Accounts.get_organization_by_id_or_handle(org_ref, actor: actor) do
      params = %{
        addresses: Enum.map(req.addresses || [], &from_proto_address_input/1),
        geofence_polygon: Enum.map(req.geofence_polygon || [], &from_proto_coord/1),
        geofence_radius_meters: req.geofence_radius_meters || 50
      }

      case Operations.create_facility(params, actor: actor, tenant: org.id) do
        {:ok, facility} -> to_facility_response(facility)
        {:error, err} -> raise_ash_error!(err)
      end
    else
      {:error, err} -> raise_ash_error!(err)
    end
  end

  def update_facility(%V1.UpdateFacilityRequest{org_id_or_handle: org_ref, id_or_business_key: id_or_key} = req, _stream) do
    actor = current_actor!()

    with {:ok, org} <- Accounts.get_organization_by_id_or_handle(org_ref, actor: actor),
         {:ok, facility} <- Operations.get_facility_by_id_or_key(id_or_key, actor: actor, tenant: org.id) do
      params = %{
        addresses: Enum.map(req.addresses || [], &from_proto_address_input/1),
        geofence_polygon: Enum.map(req.geofence_polygon || [], &from_proto_coord/1),
        geofence_radius_meters: req.geofence_radius_meters || facility.geofence_radius_meters
      }

      case Operations.update_facility(facility, params, actor: actor, tenant: org.id) do
        {:ok, updated} -> to_facility_response(updated)
        {:error, err} -> raise_ash_error!(err)
      end
    else
      {:error, err} -> raise_ash_error!(err)
    end
  end

  def archive_facility(%V1.ArchiveFacilityRequest{org_id_or_handle: org_ref, id_or_business_key: id_or_key}, _stream) do
    actor = current_actor!()

    with {:ok, org} <- Accounts.get_organization_by_id_or_handle(org_ref, actor: actor),
         {:ok, facility} <- Operations.get_facility_by_id_or_key(id_or_key, actor: actor, tenant: org.id),
         {:ok, archived} <- Operations.archive_facility(facility, actor: actor, tenant: org.id) do
      to_facility_response(archived)
    else
      {:error, err} -> raise_ash_error!(err)
    end
  end

  def unarchive_facility(%V1.UnarchiveFacilityRequest{org_id_or_handle: org_ref, id_or_business_key: id_or_key}, _stream) do
    actor = current_actor!()

    with {:ok, org} <- Accounts.get_organization_by_id_or_handle(org_ref, actor: actor),
         {:ok, facility} <- Operations.get_facility_by_id_or_key(id_or_key, actor: actor, tenant: org.id),
         {:ok, unarchived} <- Operations.unarchive_facility(facility, actor: actor, tenant: org.id) do
      to_facility_response(unarchived)
    else
      {:error, err} -> raise_ash_error!(err)
    end
  end

  def delete_facility(%V1.DeleteFacilityRequest{org_id_or_handle: org_ref, id_or_business_key: id_or_key}, _stream) do
    actor = current_actor!()

    with {:ok, org} <- Accounts.get_organization_by_id_or_handle(org_ref, actor: actor),
         {:ok, facility} <- Operations.get_facility_by_id_or_key(id_or_key, actor: actor, tenant: org.id),
         {:ok, :ok} <- Operations.delete_facility(facility, actor: actor, tenant: org.id) do
      %V1.DeleteFacilityResponse{deleted: true}
    else
      {:error, err} -> raise_ash_error!(err)
    end
  end

  # --- Helpers & Mappers ---

  defp current_actor! do
    case Process.get(:faciqor_current_actor) do
      %Accounts.User{} = user -> user
      _ -> raise GRPC.RPCError, status: GRPC.Status.unauthenticated(), message: "Unauthenticated"
    end
  end

  defp to_geo_config_response(org, updated_handles) do
    %V1.GeoProviderConfigResponse{
      organization_id: org.id,
      organization_handle: to_string(org.handle),
      map_provider: to_proto_map_provider(org.map_provider),
      geocoding_provider: to_proto_geocoding_provider(org.geocoding_provider),
      has_here_api_key: is_binary(org.here_api_key) and String.trim(org.here_api_key) != "",
      updated_organization_handles: updated_handles
    }
  end

  defp to_number_range_response(%NumberRange{} = nr) do
    %V1.NumberRangeResponse{
      id: nr.id,
      organization_id: nr.tenant_id,
      entity_type: :NUMBER_RANGE_ENTITY_TYPE_FACILITY,
      prefix: nr.prefix || "",
      start_value: nr.start_value,
      current_value: nr.current_value,
      step: nr.step,
      suffix: nr.suffix || "",
      preview_next_key: NumberRange.preview_next_key(nr)
    }
  end

  defp to_facility_response(%Operations.Facility{} = f) do
    addresses =
      (f.addresses || [])
      |> Enum.map(fn a ->
        %V1.FacilityAddressItem{
          id: a.id,
          street: a.street,
          house_number: a.house_number,
          postal_code: a.postal_code,
          city: a.city,
          country_code: a.country_code || "DE",
          latitude: Decimal.to_string(a.latitude, :normal),
          longitude: Decimal.to_string(a.longitude, :normal),
          is_primary: a.is_primary == true,
          sort_order: a.sort_order || 0
        }
      end)

    polygon =
      (f.geofence_polygon || [])
      |> Enum.map(fn pt ->
        %V1.GeoCoordinate{
          latitude: to_string(Map.get(pt, "latitude") || Map.get(pt, :latitude) || ""),
          longitude: to_string(Map.get(pt, "longitude") || Map.get(pt, :longitude) || "")
        }
      end)

    %V1.FacilityResponse{
      id: f.id,
      organization_id: f.tenant_id,
      business_key: to_string(f.business_key),
      title: f.title,
      addresses: addresses,
      geofence_polygon: polygon,
      geofence_radius_meters: f.geofence_radius_meters || 50,
      archived_at: if(f.archived_at, do: DateTime.to_iso8601(f.archived_at), else: nil),
      inserted_at: if(f.inserted_at, do: DateTime.to_iso8601(f.inserted_at), else: ""),
      updated_at: if(f.updated_at, do: DateTime.to_iso8601(f.updated_at), else: "")
    }
  end

  defp from_proto_address_input(%V1.FacilityAddressInput{} = a) do
    %{
      street: a.street,
      house_number: a.house_number,
      postal_code: a.postal_code,
      city: a.city,
      country_code: a.country_code || "DE",
      latitude: a.latitude,
      longitude: a.longitude,
      is_primary: a.is_primary == true
    }
  end

  defp from_proto_coord(%V1.GeoCoordinate{latitude: lat, longitude: lon}) do
    %{"latitude" => lat, "longitude" => lon}
  end

  defp to_proto_map_provider(:here), do: :MAP_PROVIDER_HERE
  defp to_proto_map_provider(_), do: :MAP_PROVIDER_OPENSTREETMAP

  defp to_proto_geocoding_provider(:here), do: :GEOCODING_PROVIDER_HERE
  defp to_proto_geocoding_provider(_), do: :GEOCODING_PROVIDER_NOMINATIM

  defp maybe_put_map_provider(map, :MAP_PROVIDER_OPENSTREETMAP), do: Map.put(map, :map_provider, :openstreetmap)
  defp maybe_put_map_provider(map, :MAP_PROVIDER_HERE), do: Map.put(map, :map_provider, :here)
  defp maybe_put_map_provider(map, _), do: map

  defp maybe_put_geocoding_provider(map, :GEOCODING_PROVIDER_NOMINATIM),
    do: Map.put(map, :geocoding_provider, :nominatim)

  defp maybe_put_geocoding_provider(map, :GEOCODING_PROVIDER_HERE), do: Map.put(map, :geocoding_provider, :here)
  defp maybe_put_geocoding_provider(map, _), do: map

  defp maybe_put_api_key(map, nil), do: map
  defp maybe_put_api_key(map, key), do: Map.put(map, :here_api_key, key)

  defp from_proto_entity_type(:NUMBER_RANGE_ENTITY_TYPE_FACILITY), do: :facility
  defp from_proto_entity_type(_), do: :facility

  defp maybe_put_string(map, _key, nil), do: map
  defp maybe_put_string(map, key, val), do: Map.put(map, key, val)

  defp maybe_put_int(map, _key, nil), do: map
  defp maybe_put_int(map, key, val), do: Map.put(map, key, val)

  defp raise_ash_error!(err) do
    {status, message} = IdentityService.map_ash_error_to_grpc(err)
    raise GRPC.RPCError, status: status, message: message
  end
end
