defmodule FaciqorWeb.AuthControllerTest do
  use FaciqorWeb.ConnCase, async: true

  alias Faciqor.Accounts.User

  setup do
    {:ok, user} =
      User
      |> Ash.Changeset.for_create(:sign_in_with_magic_link, %{email: "signout-test@example.com"})
      |> Ash.create()

    %{user: user}
  end

  describe "sign_out / Abmeldung" do
    test "DELETE /sign-out clears session, user_id and redirects to /sign-in", %{conn: conn, user: user} do
      conn =
        conn
        |> init_test_session(%{"user_id" => user.id})
        |> delete(~p"/sign-out")

      assert redirected_to(conn) == ~p"/sign-in"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Sie wurden erfolgreich abgemeldet."
      assert get_session(conn, "user_id") == nil
    end

    test "GET /sign-out also clears session and redirects to /sign-in", %{conn: conn, user: user} do
      conn =
        conn
        |> init_test_session(%{"user_id" => user.id})
        |> get(~p"/sign-out")

      assert redirected_to(conn) == ~p"/sign-in"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Sie wurden erfolgreich abgemeldet."
      assert get_session(conn, "user_id") == nil
    end
  end
end
