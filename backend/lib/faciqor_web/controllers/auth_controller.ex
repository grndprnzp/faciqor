defmodule FaciqorWeb.AuthController do
  use FaciqorWeb, :controller
  use AshAuthentication.Phoenix.Controller

  def success(conn, _activity, user, _token) do
    return_to = get_session(conn, :return_to) || ~p"/dashboard"

    conn
    |> store_in_session(user)
    |> assign(:current_user, user)
    |> put_session("user_id", to_string(user.id))
    |> put_flash(:info, "Willkommen bei Faciqor! Sie wurden erfolgreich angemeldet.")
    |> redirect(to: return_to)
  end

  def failure(conn, _activity, _reason) do
    conn
    |> put_flash(:error, "Anmeldung fehlgeschlagen. Der Anmeldelink ist ungültig oder abgelaufen.")
    |> redirect(to: ~p"/sign-in")
  end

  def sign_out(conn, _params) do
    conn
    |> clear_session(:faciqor)
    |> delete_session("user_id")
    |> put_flash(:info, "Erfolgreich abgemeldet.")
    |> redirect(to: ~p"/sign-in")
  end
end
