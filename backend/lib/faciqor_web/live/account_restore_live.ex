defmodule FaciqorWeb.AccountRestoreLive do
  use FaciqorWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event("restore_account", _params, socket) do
    user = socket.assigns.current_user

    case user
         |> Ash.Changeset.for_update(:restore_user, %{})
         |> Ash.update(actor: user) do
      {:ok, _restored_user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Ihr Konto und alle zugehörigen Organisationen wurden wiederhergestellt.")
         |> push_navigate(to: ~p"/dashboard")}

      {:error, _err} ->
        {:noreply, put_flash(socket, :error, "Fehler bei der Wiederherstellung des Kontos.")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-lg mx-auto mt-12 bg-[var(--fq-color-bg-surface)] border border-[var(--fq-status-danger)] rounded-lg p-6 space-y-4">
      <h1 class="text-lg font-bold text-[var(--fq-color-text-main)]">
        Konto zur Löschung vorgemerkt
      </h1>
      <p class="text-sm text-[var(--fq-color-text-muted)]">
        Ihr Benutzerkonto (<span class="fq-mono">@<%= @current_user.handle %></span>) befindet sich in der 60-tägigen Wiederherstellungsfrist.
        Die endgültige und unwiderrufliche Löschung erfolgt am:
        <span class="fq-mono font-semibold text-[var(--fq-color-text-main)]">
          <%= if @current_user.purge_at, do: Calendar.strftime(@current_user.purge_at, "%d.%m.%Y %H:%M UTC"), else: "in 60 Tagen" %>
        </span>
      </p>
      <div class="pt-2">
        <.button type="button" phx-click="restore_account">
          Konto &amp; zugehörige Organisationen jetzt wiederherstellen
        </.button>
      </div>
    </div>
    """
  end
end
