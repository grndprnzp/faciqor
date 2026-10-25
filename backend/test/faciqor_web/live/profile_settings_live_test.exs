defmodule FaciqorWeb.ProfileSettingsLiveTest do
  use FaciqorWeb.ConnCase, async: true
  require Ash.Query

  alias Faciqor.Accounts.{User, ApiToken}

  setup %{conn: conn} do
    {:ok, user} =
      User
      |> Ash.Changeset.for_create(:register_with_password, %{
        email: "profile-test@example.com",
        password: "super_secure_password_123"
      })
      |> Ash.create()

    # Confirm email for normal tests
    {:ok, verified_user} =
      user
      |> Ash.Changeset.for_update(:confirm_email, %{})
      |> Ash.update(actor: user)

    session_conn = init_test_session(conn, %{"user_id" => verified_user.id})
    %{conn: session_conn, user: verified_user}
  end

  describe "Profile & Stammdaten" do
    test "renders profile settings page and normalizes handle with @ prefix", %{conn: conn, user: user} do
      {:ok, view, html} = live(conn, ~p"/settings/profile")

      assert html =~ "Benutzerprofil &amp; Sicherheit"
      assert html =~ "Persönliche Stammdaten"

      # Submit profile with @ prefix and display name
      view
      |> form("#profile-form", %{
        "user" => %{
          "handle" => "@test_user_neu",
          "display_name" => "Test Tester",
          "first_name" => "Test",
          "last_name" => "Tester",
          "phone" => "+49 123 456789",
          "timezone" => "Europe/Berlin",
          "locale" => "de"
        }
      })
      |> render_submit()

      updated_user = Ash.get!(User, user.id, authorize?: false)
      assert to_string(updated_user.handle) == "test_user_neu"
      assert updated_user.display_name == "Test Tester"
      assert updated_user.first_name == "Test"
      assert updated_user.last_name == "Tester"
      assert updated_user.phone == "+49 123 456789"
    end
  end

  describe "Verification Resend" do
    test "unconfirmed user clicking resend_verification_email receives flash info without crashing", %{conn: base_conn} do
      {:ok, unverified_user} =
        User
        |> Ash.Changeset.for_create(:register_with_password, %{
          email: "unconfirmed-user@example.com",
          password: "super_secure_password_123"
        })
        |> Ash.create()

      conn = init_test_session(base_conn, %{"user_id" => unverified_user.id})
      {:ok, view, html} = live(conn, ~p"/settings/profile")

      assert html =~ "verification-warning-banner"

      res = render_click(view, :resend_verification_email, %{})
      assert res =~ "Bestätigungs-E-Mail wurde erneut gesendet."
    end
  end

  describe "Password Management" do
    test "changing password with valid current password succeeds and verifies new password", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, ~p"/settings/profile")

      view
      |> form("#password-form", %{
        "password" => %{
          "current_password" => "super_secure_password_123",
          "password" => "new_super_secret_pw_456",
          "password_confirmation" => "new_super_secret_pw_456"
        }
      })
      |> render_submit()

      updated_user = Ash.get!(User, user.id, authorize?: false)
      assert Bcrypt.verify_pass("new_super_secret_pw_456", updated_user.hashed_password)
      refute Bcrypt.verify_pass("super_secure_password_123", updated_user.hashed_password)
    end

    test "changing password with invalid current password fails with error", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/settings/profile")

      view
      |> form("#password-form", %{
        "password" => %{
          "current_password" => "wrong_password_here",
          "password" => "new_super_secret_pw_456",
          "password_confirmation" => "new_super_secret_pw_456"
        }
      })
      |> render_submit()

      assert render(view) =~ "Das aktuelle Passwort ist nicht korrekt."
    end
  end

  describe "E-Mail Change Workflow" do
    test "requesting and confirming email change updates primary email", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, ~p"/settings/profile")

      # Open email change form
      render_click(view, :toggle_email_change, %{})

      # Submit new email
      view
      |> form("#email-change-form", %{
        "email_change" => %{
          "new_email" => "brand-new-address@example.com"
        }
      })
      |> render_submit()

      user_with_pending = Ash.get!(User, user.id, authorize?: false)
      assert to_string(user_with_pending.pending_email) == "brand-new-address@example.com"

      # Confirm email change
      render_click(view, :confirm_email_change, %{})

      final_user = Ash.get!(User, user.id, authorize?: false)
      assert to_string(final_user.email) == "brand-new-address@example.com"
      assert is_nil(final_user.pending_email)
    end
  end

  describe "Personal Access Tokens (PAT)" do
    test "creating and revoking a personal access token", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, ~p"/settings/profile")

      view
      |> form("#pat-form", %{
        "name" => "CI Build Agent",
        "expires_in_days" => "90",
        "scopes" => "all"
      })
      |> render_submit()

      html = render(view)
      assert html =~ "CI Build Agent"
      assert html =~ "fq_pat_"
      assert html =~ "faciqor auth login --token"

      token =
        ApiToken
        |> Ash.Query.filter(user_id == ^user.id and name == "CI Build Agent")
        |> Ash.read_one!(authorize?: false)

      assert token.token_prefix != nil
      assert token.scopes == "all"

      # Revoke token
      render_click(view, :revoke_pat, %{"id" => token.id})

      revoked_token = Ash.get!(ApiToken, token.id, authorize?: false)
      assert revoked_token.revoked_at != nil
    end

    test "renders sign-out button in header and profile session card", %{conn: conn} do
      {:ok, view, html} = live(conn, ~p"/settings/profile")

      assert has_element?(view, "#header-sign-out-btn")
      assert has_element?(view, "#profile-sign-out-btn")
      assert html =~ "7. Aktive Sitzung &amp; Abmeldung"
      assert html =~ "Vom System abmelden"
    end
  end

  describe "Avatar Upload & Removal" do
    test "saving and removing avatar via LiveView", %{conn: conn, user: user} do
      {:ok, view, html} = live(conn, ~p"/settings/profile")

      assert html =~ "Avatar ändern"
      assert has_element?(view, "#avatar-cropper-trigger")
      refute has_element?(view, "header img[alt='Avatar']")

      # Generate valid 512x512 image in memory
      {:ok, img} = Image.new(512, 512, color: :blue)
      {:ok, binary} = Image.write(img, :memory, suffix: ".png")
      base64 = Base.encode64(binary)
      data_url = "data:image/png;base64,#{base64}"

      # Trigger save_avatar event
      render_hook(view, "save_avatar", %{"data" => data_url})

      # Verify user has avatar blob attached
      updated_user = Ash.get!(User, user.id, authorize?: false)
      assert updated_user.avatar_blob_id != nil

      # Check HTML renders success message, remove button and header avatar image
      html = render(view)
      assert html =~ "Avatar erfolgreich aktualisiert"
      assert html =~ "Avatar entfernen"
      assert has_element?(view, "header img[alt='Avatar']")

      # Remove avatar
      render_click(view, :remove_avatar, %{})

      user_after_removal = Ash.get!(User, user.id, authorize?: false)
      assert is_nil(user_after_removal.avatar_blob_id)
      assert render(view) =~ "Avatar wurde entfernt"
      refute has_element?(view, "header img[alt='Avatar']")
    end
  end
end
