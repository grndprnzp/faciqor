defmodule FaciqorWeb.LiveViewsTest do
  use FaciqorWeb.ConnCase, async: true

  alias Faciqor.Accounts.{User, Organization, OrganizationMembership}

  describe "7.2.1 Onboarding & Empty State" do
    test "newly registered user without organization sees guided Empty State and yellow 14-day verification banner on /dashboard",
         %{conn: conn} do
      {:ok, user} =
        User
        |> Ash.Changeset.for_create(:register_with_password, %{
          email: "newbie@example.com",
          password: "super_secure_password_123"
        })
        |> Ash.create()

      conn = init_test_session(conn, %{"user_id" => user.id})
      {:ok, _view, html} = live(conn, ~p"/dashboard")

      assert html =~ "verification-warning-banner"
      assert html =~ "onboarding-empty-state"
      assert html =~ "Erste Organisation gründen"
      assert html =~ "Benutzerprofil &amp; CLI einrichten"
    end
  end

  describe "7.2.2 Grace-Period Blocker" do
    test "unconfirmed user with inserted_at 15 days ago is redirected to /verify-email-required when accessing /dashboard or /settings/profile",
         %{conn: conn} do
      {:ok, user} =
        User
        |> Ash.Changeset.for_create(:register_with_password, %{
          email: "expired@example.com",
          password: "super_secure_password_123"
        })
        |> Ash.create()

      fifteen_days_ago = DateTime.add(DateTime.utc_now(), -15 * 86400, :second)
      Ecto.Changeset.change(user, inserted_at: fifteen_days_ago) |> Faciqor.Repo.update!()

      conn = init_test_session(conn, %{"user_id" => user.id})

      assert {:error, {:redirect, %{to: "/verify-email-required"}}} = live(conn, ~p"/dashboard")
      assert {:error, {:redirect, %{to: "/verify-email-required"}}} = live(conn, ~p"/settings/profile")
    end
  end

  describe "7.2.3 Role-Based Form Rendering" do
    test "on /orgs/:handle/settings an :owner sees editable fields while a :member or :guest finds readonly attributes",
         %{conn: conn} do
      {:ok, owner} =
        User
        |> Ash.Changeset.for_create(:sign_in_with_magic_link, %{email: "owner-ui@example.com"})
        |> Ash.create()

      {:ok, member} =
        User
        |> Ash.Changeset.for_create(:sign_in_with_magic_link, %{email: "member-ui@example.com"})
        |> Ash.create()

      {:ok, org} =
        Organization
        |> Ash.Changeset.for_create(:create_organization, %{
          handle: "hv-berlin",
          primary_focus: :property_manager
        })
        |> Ash.create(actor: owner)

      OrganizationMembership
      |> Ash.Changeset.for_create(:create_membership, %{
        user_id: member.id,
        organization_id: org.id,
        role: :member
      })
      |> Ash.create!(authorize?: false)

      # Owner view: editable inputs + save button + danger zone
      owner_conn = init_test_session(conn, %{"user_id" => owner.id})
      {:ok, _owner_view, owner_html} = live(owner_conn, ~p"/orgs/#{org.handle}/settings")
      assert owner_html =~ "Änderungen speichern"
      assert owner_html =~ "org-danger-zone"
      refute owner_html =~ "Schreibgeschützt"

      # Member view: GoBD readonly inputs, no save button, no danger zone
      member_conn = init_test_session(conn, %{"user_id" => member.id})
      {:ok, _member_view, member_html} = live(member_conn, ~p"/orgs/#{org.handle}/settings")
      assert member_html =~ "readonly"
      assert member_html =~ "Schreibgeschützt"
      refute member_html =~ "Änderungen speichern"
      refute member_html =~ "org-danger-zone"
    end
  end

  describe "7.2.4 Organization Creation & Settings Access" do
    test "creating an organization via /orgs/new registers user as owner and allows access to settings",
         %{conn: conn} do
      {:ok, user} =
        User
        |> Ash.Changeset.for_create(:register_with_password, %{
          email: "founder@example.com",
          password: "super_secure_password_123"
        })
        |> Ash.create()

      conn = init_test_session(conn, %{"user_id" => user.id})

      {:ok, view, html} = live(conn, ~p"/orgs/new")
      assert html =~ "Neue Organisation gründen"

      # Select focus
      render_click(view, :select_focus, %{"focus" => "property_manager"})

      # Toggle optional company details
      render_click(view, :toggle_optional, %{})

      # Submit form with @ prefix in handle
      {:error, {:live_redirect, %{to: target_path}}} =
        view
        |> form("form", %{
          "handle" => "@hv2-test",
          "display_name" => "Muster HV",
          "legal_name" => "Muster Hausverwaltung GmbH"
        })
        |> render_submit()

      assert target_path == "/orgs/hv2-test/settings"

      # Navigate to settings page
      {:ok, _settings_view, settings_html} = live(conn, target_path)

      # Should be owner and editable
      assert settings_html =~ "@hv2-test"
      assert settings_html =~ "Änderungen speichern"
      assert settings_html =~ "org-danger-zone"
      refute settings_html =~ "Organisation nicht gefunden oder kein Zugriff."

      # On /dashboard, the newly created org is listed and empty state is replaced
      {:ok, _dash_view, dash_html} = live(conn, ~p"/dashboard")
      assert dash_html =~ "@hv2-test"
      assert dash_html =~ "Ihre Organisationen"
      refute dash_html =~ "onboarding-empty-state"
    end

    test "unauthorized user visiting /orgs/:handle/settings is redirected with error flash",
         %{conn: conn} do
      {:ok, owner} =
        User
        |> Ash.Changeset.for_create(:register_with_password, %{
          email: "real-owner@example.com",
          password: "super_secure_password_123"
        })
        |> Ash.create()

      {:ok, stranger} =
        User
        |> Ash.Changeset.for_create(:register_with_password, %{
          email: "stranger-live@example.com",
          password: "super_secure_password_123"
        })
        |> Ash.create()

      {:ok, org} =
        Faciqor.Accounts.create_organization(
          %{
            handle: "top-secret-org",
            primary_focus: :property_owner
          },
          actor: owner
        )

      stranger_conn = init_test_session(conn, %{"user_id" => stranger.id})

      # Mounting /orgs/top-secret-org/settings as stranger redirects to dashboard
      assert {:error, {:live_redirect, %{to: "/dashboard", flash: %{"error" => "Organisation nicht gefunden oder kein Zugriff."}}}} =
               live(stranger_conn, ~p"/orgs/#{org.handle}/settings")
    end
  end

  describe "7.2.5 Sign-Out & Escape Hatches" do
    test "provides sign-out escape hatch on /verify-email-required", %{conn: conn} do
      {:ok, user} =
        User
        |> Ash.Changeset.for_create(:register_with_password, %{
          email: "must-verify@example.com",
          password: "super_secure_password_123"
        })
        |> Ash.create()

      conn = init_test_session(conn, %{"user_id" => user.id})
      {:ok, view, html} = live(conn, ~p"/verify-email-required")

      assert has_element?(view, "#verify-sign-out-btn")
      assert html =~ "Abmelden"
    end

    test "provides sign-out escape hatch on /account/restore", %{conn: conn} do
      {:ok, user} =
        User
        |> Ash.Changeset.for_create(:sign_in_with_magic_link, %{email: "restore-user@example.com"})
        |> Ash.create()

      {:ok, deleted_user} =
        user
        |> Ash.Changeset.for_update(:soft_delete_user, %{})
        |> Ash.update(actor: user)

      conn = init_test_session(conn, %{"user_id" => deleted_user.id})
      {:ok, view, html} = live(conn, ~p"/account/restore")

      assert has_element?(view, "#restore-sign-out-btn")
      assert html =~ "Abmelden"
    end
  end
end
