defmodule FaciqorGrpc.OperationsServiceTest do
  use Faciqor.DataCase, async: true

  alias Faciqor.Accounts
  alias Faciqor.Accounts.User
  alias Faciqor.V1
  alias FaciqorGrpc.Services.OperationsService

  setup do
    {:ok, user} =
      User
      |> Ash.Changeset.for_create(:sign_in_with_magic_link, %{email: "grpc-ops@example.com"})
      |> Ash.create()

    {:ok, org_1} =
      Accounts.create_organization(
        %{handle: "grpc-org-1", primary_focus: :property_manager},
        actor: user
      )

    {:ok, org_2} =
      Accounts.create_organization(
        %{handle: "grpc-org-2", primary_focus: :property_owner},
        actor: user
      )

    Process.put(:faciqor_current_actor, user)

    %{user: user, org_1: org_1, org_2: org_2}
  end

  describe "7.3.1 OperationsService gRPC Endpoints" do
    test "manages number ranges, geo providers and full facility lifecycle via gRPC",
         %{org_1: org_1, org_2: org_2} do
      # 1. GetNumberRange
      nr_res =
        OperationsService.get_number_range(
          %V1.GetNumberRangeRequest{
            org_id_or_handle: org_1.handle,
            entity_type: :NUMBER_RANGE_ENTITY_TYPE_FACILITY
          },
          nil
        )

      assert nr_res.prefix == "OBJ-"
      assert nr_res.start_value == 1000
      assert nr_res.preview_next_key == "OBJ-1000"

      # 2. UpdateNumberRange
      nr_upd =
        OperationsService.update_number_range(
          %V1.UpdateNumberRangeRequest{
            org_id_or_handle: org_1.handle,
            entity_type: :NUMBER_RANGE_ENTITY_TYPE_FACILITY,
            prefix: "LI-",
            start_value: 500,
            step: 10,
            suffix: "-B"
          },
          nil
        )

      assert nr_upd.preview_next_key == "LI-500-B"

      # 3. UpdateGeoProviderConfig (with bulk apply_to_all_owned_orgs)
      geo_upd =
        OperationsService.update_geo_provider_config(
          %V1.UpdateGeoProviderConfigRequest{
            org_id_or_handle: org_1.handle,
            map_provider: :MAP_PROVIDER_HERE,
            geocoding_provider: :GEOCODING_PROVIDER_HERE,
            here_api_key: "grpc-here-key-42",
            apply_to_all_owned_orgs: true
          },
          nil
        )

      assert geo_upd.map_provider == :MAP_PROVIDER_HERE
      assert geo_upd.geocoding_provider == :GEOCODING_PROVIDER_HERE
      assert geo_upd.has_here_api_key == true
      assert Enum.sort(geo_upd.updated_organization_handles) == ["grpc-org-1", "grpc-org-2"]

      geo_org_2 =
        OperationsService.get_geo_provider_config(
          %V1.GetGeoProviderConfigRequest{org_id_or_handle: org_2.handle},
          nil
        )

      assert geo_org_2.map_provider == :MAP_PROVIDER_HERE
      assert geo_org_2.has_here_api_key == true

      # 4. CreateFacility (with 123, 125, 127 Main Street)
      fac_res =
        OperationsService.create_facility(
          %V1.CreateFacilityRequest{
            org_id_or_handle: org_1.handle,
            addresses: [
              %V1.FacilityAddressInput{
                street: "Main Street",
                house_number: "123",
                postal_code: "10115",
                city: "Berlin",
                is_primary: true
              },
              %V1.FacilityAddressInput{
                street: "Main Street",
                house_number: "125",
                postal_code: "10115",
                city: "Berlin"
              },
              %V1.FacilityAddressInput{
                street: "Main Street",
                house_number: "127",
                postal_code: "10115",
                city: "Berlin"
              }
            ],
            geofence_radius_meters: 55
          },
          nil
        )

      assert fac_res.business_key == "LI-500-B"
      assert fac_res.title == "Main Street 123,125,127"
      assert length(fac_res.addresses) == 3
      assert length(fac_res.geofence_polygon) == 8

      # 5. ListFacilities & GetFacility
      list_res =
        OperationsService.list_facilities(
          %V1.ListFacilitiesRequest{org_id_or_handle: org_1.handle, include_archived: false},
          nil
        )

      assert length(list_res.facilities) == 1

      fetched =
        OperationsService.get_facility(
          %V1.GetFacilityRequest{
            org_id_or_handle: org_1.handle,
            id_or_business_key: "LI-500-B"
          },
          nil
        )

      assert fetched.id == fac_res.id

      # 6. Archive & Unarchive
      archived =
        OperationsService.archive_facility(
          %V1.ArchiveFacilityRequest{
            org_id_or_handle: org_1.handle,
            id_or_business_key: "LI-500-B"
          },
          nil
        )

      assert not is_nil(archived.archived_at)

      unarchived =
        OperationsService.unarchive_facility(
          %V1.UnarchiveFacilityRequest{
            org_id_or_handle: org_1.handle,
            id_or_business_key: "LI-500-B"
          },
          nil
        )

      assert is_nil(unarchived.archived_at)

      # 7. DeleteFacility
      del_res =
        OperationsService.delete_facility(
          %V1.DeleteFacilityRequest{
            org_id_or_handle: org_1.handle,
            id_or_business_key: "LI-500-B"
          },
          nil
        )

      assert del_res.deleted == true
    end
  end
end
