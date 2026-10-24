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
end
