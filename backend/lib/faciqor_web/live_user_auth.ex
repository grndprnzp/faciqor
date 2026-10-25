defmodule FaciqorWeb.LiveUserAuth do
  @moduledoc """
  LiveView `on_mount` hooks enforcing authentication, 60-day soft-delete restoration,
  and the 14-day email verification grace period according to REQ-M1-BOILERPLATE.
  """
  import Phoenix.Component
  import Phoenix.LiveView
  require Ash.Query

  alias Faciqor.Accounts

  def on_mount(:live_user_optional, _params, session, socket) do
    user = load_user_from_session(session)
    {:cont, assign(socket, :current_user, user)}
  end

  def on_mount(:live_user_required, _params, session, socket) do
    case load_user_from_session(session) do
      nil ->
        {:halt, redirect(socket, to: "/sign-in")}

      %Accounts.User{deleted_at: deleted_at} = user when not is_nil(deleted_at) ->
        {:halt, redirect(assign(socket, :current_user, user), to: "/account/restore")}

      %Accounts.User{verification_grace_expired?: true} = user ->
        {:halt, redirect(assign(socket, :current_user, user), to: "/verify-email-required")}

      %Accounts.User{} = user ->
        orgs = load_user_orgs(user)
        current_org = List.first(orgs)

        socket =
          socket
          |> assign(:current_user, user)
          |> assign(:user_orgs, orgs)
          |> assign(:current_org, current_org)

        {:cont, socket}
    end
  end

  def on_mount(:live_restore_only, _params, session, socket) do
    case load_user_from_session(session) do
      nil ->
        {:halt, redirect(socket, to: "/sign-in")}

      %Accounts.User{deleted_at: nil} = user ->
        {:halt, redirect(assign(socket, :current_user, user), to: "/dashboard")}

      %Accounts.User{} = user ->
        socket =
          socket
          |> assign(:current_user, user)
          |> assign(:current_org, nil)

        {:cont, socket}
    end
  end

  def on_mount(:live_verify_required_only, _params, session, socket) do
    case load_user_from_session(session) do
      nil ->
        {:halt, redirect(socket, to: "/sign-in")}

      %Accounts.User{email_confirmed_at: confirmed_at} = user when not is_nil(confirmed_at) ->
        {:halt, redirect(assign(socket, :current_user, user), to: "/dashboard")}

      %Accounts.User{} = user ->
        socket =
          socket
          |> assign(:current_user, user)
          |> assign(:current_org, nil)

        {:cont, socket}
    end
  end

  defp load_user_from_session(session) do
    user_id = session["user_id"] || extract_user_id_from_subject(session["user"])

    if user_id do
      Accounts.User
      |> Ash.Query.filter(id == ^user_id)
      |> Ash.Query.load([:email_verified?, :verification_grace_expired?, :purge_at])
      |> Ash.read_one(authorize?: false)
      |> case do
        {:ok, user} -> user
        _ -> nil
      end
    else
      nil
    end
  end

  defp extract_user_id_from_subject("user?id=" <> id), do: id
  defp extract_user_id_from_subject(_), do: nil

  defp load_user_orgs(user) do
    Accounts.Organization
    |> Ash.Query.filter(is_nil(deleted_at))
    |> Ash.Query.load(:memberships)
    |> Ash.read!(actor: user)
  end
end
