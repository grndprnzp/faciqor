defmodule FaciqorWeb.FacilitiesAndSettingsLiveTest do
  use FaciqorWeb.ConnCase, async: true

  alias Faciqor.Accounts
  alias Faciqor.Accounts.{OrganizationMembership, User}

  setup %{conn: conn} do
    {:ok, owner} =
      User
      |> Ash.Changeset.for_create(:sign_in_with_magic_link, %{email: "live-ops-owner@example.com"})
      |> Ash.create()

    {:ok, guest} =
      User
      |> Ash.Changeset.for_create(:sign_in_with_magic_link, %{email: "live-ops-guest@example.com"})
      |> Ash.create()

    {:ok, org_1} =
      Accounts.create_organization(
        %{handle: "hv-live-1", primary_focus: :property_manager},
        actor: owner
      )

    {:ok, org_2} =
      Accounts.create_organization(
        %{handle: "hv-live-2", primary_focus: :property_owner},
        actor: owner
      )

    OrganizationMembership
    |> Ash.Changeset.for_create(:create_membership, %{
      user_id: guest.id,
      organization_id: org_1.id,
      role: :guest
    })
    |> Ash.create!(authorize?: false)

    owner_conn = init_test_session(conn, %{"user_id" => owner.id})
    guest_conn = init_test_session(conn, %{"user_id" => guest.id})

    %{
      owner: owner,
      guest: guest,
      org_1: org_1,
      org_2: org_2,
      owner_conn: owner_conn,
      guest_conn: guest_conn
    }
  end

  describe "7.2.1 Facility Creation, Multi-Hit Selection & Range Expansion" do
    test "creates facility with range expansion, multi-hit disambiguation and automatic title preview",
         %{owner_conn: conn, org_1: org} do
      {:ok, view, html} = live(conn, ~p"/orgs/#{org.handle}/facilities/new")
      assert html =~ "Neues Objekt anlegen"
      assert html =~ "OBJ-1000"
      assert has_element?(view, "#facility-map-wrapper[phx-update='ignore']")

      # 1. Trigger multi-hit search ("Musterstraße 1" without city returns Berlin & München in Mock provider)
      html =
        view
        |> form("#facility-address-search-form", %{"query" => "Musterstraße 1", "parity_filter" => "all"})
        |> render_submit()

      assert html =~ "Mehrfachtreffer in der Geo-Suche gefunden"
      assert has_element?(view, "#disambiguation-panel")
      assert html =~ "Musterstraße 1, 10115 Berlin"
      assert html =~ "Musterstraße 1, 80331 München"

      # Select the first candidate (Berlin)
      html =
        view
        |> element("#select-candidate-0-0")
        |> render_click()

      refute has_element?(view, "#disambiguation-panel")
      assert html =~ "Musterstraße 1"

      # Remove Musterstraße 1 to test Hauptstraße 10-13 range expansion
      view
      |> element("#remove-address-0")
      |> render_click()

      # 2. Add range "Hauptstraße 10-13, 10115 Berlin"
      html =
        view
        |> form("#facility-address-search-form", %{
          "query" => "Hauptstraße 10-13, 10115 Berlin",
          "parity_filter" => "all"
        })
        |> render_submit()

      assert html =~ "Hauptstraße 10-13"
      assert has_element?(view, "#facility-addresses-table")

      # Adjust geofence radius
      view
      |> form("#geofence-radius-form", %{"radius" => "85"})
      |> render_change()

      # Save facility
      {:error, {:live_redirect, %{to: redirect_to}}} =
        view
        |> element("#save-facility-btn")
        |> render_click()

      assert redirect_to == "/orgs/#{org.handle}/facilities"

      # Verify facility appears on index page with BusinessKey OBJ-1000 and Title "Hauptstraße 10-13"
      {:ok, index_view, index_html} = live(conn, redirect_to)
      assert index_html =~ "OBJ-1000"
      assert index_html =~ "Hauptstraße 10-13"
      assert index_html =~ "4 Adresse(n)"
      assert has_element?(index_view, "#facilities-table")
    end

    test "guest is redirected from /new and sees readonly view on existing facility",
         %{owner_conn: owner_conn, guest_conn: guest_conn, owner: owner, org_1: org} do
      {:ok, facility} =
        Faciqor.Operations.create_facility(
          %{
            addresses: [
              %{
                street: "Lauterberger Straße",
                house_number: "32",
                postal_code: "12347",
                city: "Berlin",
                latitude: "52.4510000",
                longitude: "13.4420000"
              },
              %{
                street: "Walkenrieder Straße",
                house_number: "4",
                postal_code: "12347",
                city: "Berlin",
                latitude: "52.4511000",
                longitude: "13.4422000"
              }
            ]
          },
          actor: owner,
          tenant: org.id
        )

      # Guest cannot access /new
      assert {:error, {:live_redirect, %{to: "/orgs/hv-live-1/facilities"}}} =
               live(guest_conn, ~p"/orgs/#{org.handle}/facilities/new")

      # Guest can view detail page in readonly mode (no save button, no search form)
      {:ok, guest_view, guest_html} = live(guest_conn, ~p"/orgs/#{org.handle}/facilities/#{facility.id}")
      assert guest_html =~ "Lauterberger Straße 32 - Walkenrieder Straße 4"
      refute has_element?(guest_view, "#save-facility-btn")
      refute has_element?(guest_view, "#facility-address-search-form")

      # Owner can edit
      {:ok, owner_view, _owner_html} = live(owner_conn, ~p"/orgs/#{org.handle}/facilities/#{facility.id}")
      assert has_element?(owner_view, "#save-facility-btn")
    end
  end

  describe "7.2.2 Organization Settings: Number Ranges & Geo Provider Bulk Update" do
    test "updates number range with live preview and bulk-updates geo provider across owned organizations",
         %{owner_conn: conn, owner: owner, org_1: org_1, org_2: org_2} do
      {:ok, view, html} = live(conn, ~p"/orgs/#{org_1.handle}/settings")
      assert html =~ "Sektion C – Nummernkreise"
      assert html =~ "Sektion D – Kartenanbieter &amp; Geo-Suche"
      assert html =~ "OBJ-1000"

      # Live preview change on number range form
      preview_html =
        view
        |> form("#org-number-range-form", %{
          "prefix" => "OG-",
          "start_value" => "2000",
          "step" => "5",
          "suffix" => "-A"
        })
        |> render_change()

      assert preview_html =~ "OG-2000-A"

      # Submit number range form
      saved_nr_html =
        view
        |> form("#org-number-range-form", %{
          "prefix" => "OG-",
          "start_value" => "2000",
          "step" => "5",
          "suffix" => "-A"
        })
        |> render_submit()

      assert saved_nr_html =~ "Nummernkreis erfolgreich gespeichert."

      # Submit geo provider form with apply_to_all_owned_orgs = "true"
      saved_geo_html =
        view
        |> form("#org-geo-provider-form", %{
          "map_provider" => "here",
          "geocoding_provider" => "here",
          "here_api_key" => "live-here-api-key-999",
          "apply_to_all_owned_orgs" => "true"
        })
        |> render_submit()

      assert saved_geo_html =~ "Karten- &amp; Geo-Provider für 2 Organisationen gespeichert"

      # Verify org_2 also received the HERE provider settings
      {:ok, reloaded_2} = Accounts.get_organization_by_id_or_handle(org_2.id, actor: owner)
      assert reloaded_2.map_provider == :here
      assert reloaded_2.geocoding_provider == :here
      assert reloaded_2.here_api_key == "live-here-api-key-999"
    end
  end
end
