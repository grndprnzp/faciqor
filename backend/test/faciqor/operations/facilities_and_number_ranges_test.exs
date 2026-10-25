defmodule Faciqor.Operations.FacilitiesAndNumberRangesTest do
  use Faciqor.DataCase, async: true

  alias Faciqor.Accounts
  alias Faciqor.Accounts.{OrganizationMembership, User}
  alias Faciqor.Operations
  alias Faciqor.Operations.NumberRange
  alias Faciqor.Repo

  setup do
    {:ok, owner} =
      User
      |> Ash.Changeset.for_create(:sign_in_with_magic_link, %{email: "ops-owner@example.com"})
      |> Ash.create()

    {:ok, member} =
      User
      |> Ash.Changeset.for_create(:sign_in_with_magic_link, %{email: "ops-member@example.com"})
      |> Ash.create()

    {:ok, guest} =
      User
      |> Ash.Changeset.for_create(:sign_in_with_magic_link, %{email: "ops-guest@example.com"})
      |> Ash.create()

    {:ok, stranger} =
      User
      |> Ash.Changeset.for_create(:sign_in_with_magic_link, %{email: "ops-stranger@example.com"})
      |> Ash.create()

    {:ok, org_a} =
      Accounts.create_organization(
        %{handle: "ops-org-a", primary_focus: :property_manager},
        actor: owner
      )

    {:ok, org_b} =
      Accounts.create_organization(
        %{handle: "ops-org-b", primary_focus: :property_owner},
        actor: owner
      )

    {:ok, org_c} =
      Accounts.create_organization(
        %{handle: "ops-org-c", primary_focus: :service_provider},
        actor: stranger
      )

    OrganizationMembership
    |> Ash.Changeset.for_create(:create_membership, %{
      user_id: member.id,
      organization_id: org_a.id,
      role: :member
    })
    |> Ash.create!(authorize?: false)

    OrganizationMembership
    |> Ash.Changeset.for_create(:create_membership, %{
      user_id: guest.id,
      organization_id: org_a.id,
      role: :guest
    })
    |> Ash.create!(authorize?: false)

    # Owner is only :member in org_c
    OrganizationMembership
    |> Ash.Changeset.for_create(:create_membership, %{
      user_id: owner.id,
      organization_id: org_c.id,
      role: :member
    })
    |> Ash.create!(authorize?: false)

    %{
      owner: owner,
      member: member,
      guest: guest,
      stranger: stranger,
      org_a: org_a,
      org_b: org_b,
      org_c: org_c
    }
  end

  describe "7.1.2 Number Ranges & Macros" do
    test "seeds default number range on organization creation and allocates keys with macros",
         %{owner: owner, org_a: org_a} do
      assert {:ok, nr} = Operations.get_number_range(:facility, actor: owner, tenant: org_a.id)
      assert nr.prefix == "OBJ-"
      assert nr.start_value == 1000
      assert is_nil(nr.current_value)
      assert nr.step == 1
      assert NumberRange.preview_next_key(nr) == "OBJ-1000"

      # Update with date macros and step 10
      assert {:ok, updated_nr} =
               Operations.update_number_range(
                 %{
                   prefix: "OG-{{Jahr}}-{{Monat}}-",
                   start_value: 100,
                   step: 10,
                   suffix: "-A"
                 },
                 actor: owner,
                 tenant: org_a.id
               )

      fixed_date = ~D[2026-10-25]
      assert NumberRange.preview_next_key(updated_nr, fixed_date) == "OG-2026-10-100-A"

      key1 = Operations.allocate_next_business_key!(org_a.id, :facility, fixed_date)
      assert key1 == "OG-2026-10-100-A"

      key2 = Operations.allocate_next_business_key!(org_a.id, :facility, fixed_date)
      assert key2 == "OG-2026-10-110-A"
    end
  end

  describe "7.1.3 Facilities, PostGIS Storage, Geofence Validation & RLS Role Matrix" do
    test "creates facility with corner addresses, stores PostGIS Point/Polygon and enforces business_key immutability",
         %{owner: owner, member: member, guest: guest, stranger: stranger, org_a: org_a, org_b: org_b} do
      params = %{
        addresses: [
          %{
            street: "Lauterberger Straße",
            house_number: "32",
            postal_code: "12347",
            city: "Berlin",
            latitude: "52.4510000",
            longitude: "13.4420000",
            is_primary: true
          },
          %{
            street: "Walkenrieder Straße",
            house_number: "4",
            postal_code: "12347",
            city: "Berlin",
            latitude: "52.4511000",
            longitude: "13.4422000",
            is_primary: false
          }
        ],
        geofence_radius_meters: 60
      }

      # Member can create a facility in org_a
      assert {:ok, facility} = Operations.create_facility(params, actor: member, tenant: org_a.id)
      assert to_string(facility.business_key) == "OBJ-1000"
      assert facility.title == "Lauterberger Straße 32 - Walkenrieder Straße 4"
      assert length(facility.addresses) == 2

      # Verify native PostGIS GEOGRAPHY(Polygon, 4326) and GEOGRAPHY(Point, 4326) in database
      %{rows: [[poly_wkt, covers_all]]} =
        Ecto.Adapters.SQL.query!(
          Repo,
          """
          SELECT
            ST_AsText(f.geofence_zone::geometry),
            bool_and(ST_Covers(f.geofence_zone::geometry, a.location::geometry))
          FROM facilities f
          JOIN facility_addresses a ON a.facility_id = f.id
          WHERE f.id = $1::uuid
          GROUP BY f.id;
          """,
          [Ecto.UUID.dump!(facility.id)]
        )

      assert String.starts_with?(poly_wkt, "POLYGON((")
      assert covers_all == true

      # Guest can read facility in org_a, but cannot create or update
      assert {:ok, [read_by_guest]} = Operations.list_facilities(actor: guest, tenant: org_a.id)
      assert read_by_guest.id == facility.id

      assert {:error, %Ash.Error.Forbidden{}} =
               Operations.create_facility(params, actor: guest, tenant: org_a.id)

      assert {:error, %Ash.Error.Forbidden{}} =
               Operations.update_facility(facility, %{geofence_radius_meters: 80}, actor: guest, tenant: org_a.id)

      # Stranger (non-member) cannot read or create in org_a
      assert {:error, %Ash.Error.Forbidden{}} =
               Operations.list_facilities(actor: stranger, tenant: org_a.id)

      # Multi-tenancy isolation: org_b has 0 facilities
      assert {:ok, []} = Operations.list_facilities(actor: owner, tenant: org_b.id)

      # Updating addresses recalculates title while business_key stays immutable ("OBJ-1000")
      update_params = %{
        addresses: [
          %{
            street: "Hauptstraße",
            house_number: "10",
            postal_code: "10115",
            city: "Berlin",
            latitude: "52.5200000",
            longitude: "13.4050000"
          },
          %{
            street: "Hauptstraße",
            house_number: "11",
            postal_code: "10115",
            city: "Berlin",
            latitude: "52.5200500",
            longitude: "13.4050500"
          },
          %{
            street: "Hauptstraße",
            house_number: "12",
            postal_code: "10115",
            city: "Berlin",
            latitude: "52.5201000",
            longitude: "13.4051000"
          },
          %{
            street: "Hauptstraße",
            house_number: "13",
            postal_code: "10115",
            city: "Berlin",
            latitude: "52.5201500",
            longitude: "13.4051500"
          }
        ]
      }

      assert {:ok, updated} =
               Operations.update_facility(facility, update_params, actor: member, tenant: org_a.id)

      assert to_string(updated.business_key) == "OBJ-1000"
      assert updated.title == "Hauptstraße 10-13"
      assert length(updated.addresses) == 4

      # Member cannot delete facility (only :owner can)
      assert {:error, %Ash.Error.Forbidden{}} =
               Operations.delete_facility(updated, actor: member, tenant: org_a.id)

      # Owner can delete facility
      assert {:ok, :ok} = Operations.delete_facility(updated, actor: owner, tenant: org_a.id)
      assert {:ok, []} = Operations.list_facilities(actor: owner, tenant: org_a.id)
    end

    test "rejects geofence polygon that does not cover the facility addresses",
         %{owner: owner, org_a: org_a} do
      # Address in Berlin (52.52, 13.40), polygon far away in Munich (48.13, 11.58)
      params = %{
        addresses: [
          %{
            street: "Hauptstraße",
            house_number: "10",
            postal_code: "10115",
            city: "Berlin",
            latitude: "52.5200000",
            longitude: "13.4050000"
          }
        ],
        geofence_polygon: [
          %{"latitude" => "48.1350000", "longitude" => "11.5800000"},
          %{"latitude" => "48.1360000", "longitude" => "11.5800000"},
          %{"latitude" => "48.1360000", "longitude" => "11.5820000"},
          %{"latitude" => "48.1350000", "longitude" => "11.5820000"}
        ]
      }

      assert {:error, %Ash.Error.Invalid{} = err} =
               Operations.create_facility(params, actor: owner, tenant: org_a.id)

      assert Exception.message(err) =~ "Geofence-Zone muss alle Teiladressen des Objekts umschließen"
    end
  end

  describe "7.1.4 Geo Provider Configuration & Bulk Update" do
    test "validates HERE API key requirement and bulk-updates only organizations where actor is :owner",
         %{owner: owner, stranger: stranger, org_a: org_a, org_b: org_b, org_c: org_c} do
      # Selecting :here without API key fails validation
      assert {:error, _} =
               Accounts.update_geo_provider_config(
                 org_a,
                 %{map_provider: :here, geocoding_provider: :here, here_api_key: nil},
                 actor: owner,
                 apply_to_all_owned_orgs: false
               )

      # Bulk update across all owned orgs (org_a and org_b, NOT org_c where owner is only :member)
      assert {:ok, updated_a, handles} =
               Accounts.update_geo_provider_config(
                 org_a,
                 %{
                   map_provider: :here,
                   geocoding_provider: :here,
                   here_api_key: "here-secret-key-123"
                 },
                 actor: owner,
                 apply_to_all_owned_orgs: true
               )

      assert updated_a.map_provider == :here
      assert updated_a.geocoding_provider == :here
      assert Enum.sort(handles) == ["ops-org-a", "ops-org-b"]

      {:ok, reloaded_b} = Accounts.get_organization_by_id_or_handle(org_b.id, actor: owner)
      assert reloaded_b.map_provider == :here
      assert reloaded_b.geocoding_provider == :here
      assert reloaded_b.here_api_key == "here-secret-key-123"

      {:ok, reloaded_c} = Accounts.get_organization_by_id_or_handle(org_c.id, actor: stranger)
      assert reloaded_c.map_provider == :openstreetmap
      assert reloaded_c.geocoding_provider == :nominatim
      assert is_nil(reloaded_c.here_api_key)
    end
  end
end
