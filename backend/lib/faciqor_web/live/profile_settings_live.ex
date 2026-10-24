defmodule FaciqorWeb.ProfileSettingsLive do
  use FaciqorWeb, :live_view
  require Ash.Query

  alias Faciqor.Accounts

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    tokens = load_active_tokens(user)
    orphaned_orgs = Accounts.list_orphaned_organizations_for_user(user.id)

    {:ok,
     socket
     |> assign(:handle_input, to_string(user.handle))
     |> assign(:handle_errors, [])
     |> assign(:api_tokens, tokens)
     |> assign(:new_token_name, "")
     |> assign(:newly_created_plain_token, nil)
     |> assign(:orphaned_orgs, orphaned_orgs)
     |> assign(:delete_confirm_handle, "")}
  end

  @impl true
  def handle_event("validate_profile", %{"handle" => handle}, socket) do
    errors = validate_handle_format(handle)
    {:noreply, socket |> assign(:handle_input, handle) |> assign(:handle_errors, errors)}
  end

  def handle_event("save_profile", %{"handle" => handle}, socket) do
    user = socket.assigns.current_user

    case user
         |> Ash.Changeset.for_update(:update_profile, %{handle: handle})
         |> Ash.update(actor: user) do
      {:ok, updated_user} ->
        {:noreply,
         socket
         |> assign(:current_user, updated_user)
         |> assign(:handle_input, to_string(updated_user.handle))
         |> assign(:handle_errors, [])
         |> put_flash(:info, "Benutzerprofil erfolgreich aktualisiert.")}

      {:error, _err} ->
        {:noreply,
         socket
         |> assign(:handle_errors, ["Handle ist bereits vergeben oder hat ein ungültiges Format."])
         |> put_flash(:error, "Handle konnte nicht gespeichert werden.")}
    end
  end

  def handle_event("create_pat", %{"name" => name}, socket) do
    user = socket.assigns.current_user

    case Accounts.create_personal_access_token(name, actor: user) do
      {:ok, plain_token, _record} ->
        {:noreply,
         socket
         |> assign(:newly_created_plain_token, plain_token)
         |> assign(:new_token_name, "")
         |> assign(:api_tokens, load_active_tokens(user))
         |> put_flash(:info, "Neues Personal Access Token wurde erstellt.")}

      {:error, _err} ->
        {:noreply, put_flash(socket, :error, "Token-Erstellung fehlgeschlagen (E-Mail-Verifizierung erforderlich).")}
    end
  end

  def handle_event("revoke_pat", %{"id" => token_id}, socket) do
    user = socket.assigns.current_user

    case Accounts.ApiToken
         |> Ash.Query.filter(id == ^token_id and user_id == ^user.id)
         |> Ash.read_one(actor: user) do
      {:ok, %Accounts.ApiToken{} = token} ->
        _ = token |> Ash.Changeset.for_update(:revoke, %{}) |> Ash.update(actor: user)
        {:noreply, assign(socket, :api_tokens, load_active_tokens(user))}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("update_delete_confirm", %{"confirm_handle" => val}, socket) do
    {:noreply, assign(socket, :delete_confirm_handle, val)}
  end

  def handle_event("request_account_deletion", _params, socket) do
    user = socket.assigns.current_user

    if String.downcase(socket.assigns.delete_confirm_handle) == String.downcase(to_string(user.handle)) do
      case user
           |> Ash.Changeset.for_update(:soft_delete_user, %{})
           |> Ash.update(actor: user) do
        {:ok, _deleted_user} ->
          {:noreply,
           socket
           |> put_flash(:info, "Ihr Konto wurde zur Löschung vorgemerkt (60 Tage Wiederherstellungsfrist).")
           |> push_navigate(to: ~p"/account/restore")}

        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Konto-Löschung konnte nicht durchgeführt werden.")}
      end
    else
      {:noreply, put_flash(socket, :error, "Bitte geben Sie zur Bestätigung Ihr exaktes Handle ein.")}
    end
  end

  defp validate_handle_format(handle) do
    if Regex.match?(~r/^[a-z0-9][a-z0-9_-]{2,30}$/, String.downcase(handle)) do
      []
    else
      ["Erlaubt sind 3-31 Zeichen (Kleinbuchstaben, Zahlen, '-' und '_')."]
    end
  end

  defp load_active_tokens(user) do
    Accounts.ApiToken
    |> Ash.Query.filter(user_id == ^user.id and is_nil(revoked_at))
    |> Ash.read!(actor: user)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div>
        <h1 class="text-2xl font-bold text-[var(--fq-color-text-main)]">Benutzerprofil &amp; Sicherheit</h1>
        <p class="text-sm text-[var(--fq-color-text-muted)]">
          Verwalten Sie Ihr persönliches Handle, Ihre CLI-Zugangstokens und Ihren Kontostatus.
        </p>
      </div>

      <%!-- Card 1: User Profile --%>
      <section class="bg-[var(--fq-color-bg-surface)] border border-[var(--fq-color-border)] rounded-lg p-6 space-y-4">
        <h2 class="text-base font-bold text-[var(--fq-color-text-main)]">1. Benutzerprofil</h2>
        <form phx-change="validate_profile" phx-submit="save_profile" class="space-y-4 max-w-lg">
          <.input
            id="profile-handle"
            name="handle"
            label="Benutzer-Handle"
            prefix="@"
            monospace={true}
            value={@handle_input}
            errors={@handle_errors}
            phx-debounce="300"
            required
          />

          <div class="space-y-1">
            <div class="flex items-center justify-between">
              <span class="text-sm font-medium text-[var(--fq-color-text-main)]">Primäre E-Mail-Adresse</span>
              <%= if @current_user.email_confirmed_at do %>
                <.status_badge status={:verified} />
              <% else %>
                <.status_badge status={:unverified} />
              <% end %>
            </div>
            <.input
              id="profile-email"
              name="email"
              type="email"
              value={to_string(@current_user.email)}
              readonly={true}
            />
          </div>

          <.button type="submit" disabled={@handle_errors != []}>
            Profil speichern
          </.button>
        </form>
      </section>

      <%!-- Card 2: Personal Access Tokens (Go-CLI & gRPC) --%>
      <section class="bg-[var(--fq-color-bg-surface)] border border-[var(--fq-color-border)] rounded-lg p-6 space-y-4">
        <div>
          <h2 class="text-base font-bold text-[var(--fq-color-text-main)]">2. Personal Access Tokens (Go-CLI &amp; gRPC)</h2>
          <p class="text-xs text-[var(--fq-color-text-muted)]">
            Token für den authentifizierten Zugriff über die <span class="fq-mono">faciqor</span> Standalone-CLI.
          </p>
        </div>

        <%= if is_nil(@current_user.email_confirmed_at) do %>
          <div class="p-3 rounded-md bg-[#FFFBEB] border border-[#F59E0B] text-xs text-[#92400E]">
            Verifizieren Sie zuerst Ihre E-Mail-Adresse, um den CLI-Zugang freizuschalten.
          </div>
        <% end %>

        <div :if={@newly_created_plain_token} class="p-4 rounded-md bg-[#ECFDF5] border border-[#10B981] space-y-2">
          <p class="text-xs font-semibold text-[#065F46]">
            Bitte kopieren Sie Ihr neues Token jetzt. Es wird aus Sicherheitsgründen nur einmalig im Klartext angezeigt:
          </p>
          <div class="p-2 rounded bg-white border border-[#6EE7B7] fq-mono text-xs select-all">
            <%= @newly_created_plain_token %>
          </div>
          <p class="text-xs text-[#065F46]">CLI-Anmeldebefehl:</p>
          <code class="block p-2 rounded bg-white border border-[#6EE7B7] fq-mono text-xs select-all">
            faciqor auth login --token <%= @newly_created_plain_token %>
          </code>
        </div>

        <form phx-submit="create_pat" class="flex items-end gap-3 max-w-lg">
          <div class="flex-1">
            <.input
              id="new-token-name"
              name="name"
              label="Token-Bezeichnung"
              placeholder="z. B. Workstation CLI"
              value={@new_token_name}
              readonly={is_nil(@current_user.email_confirmed_at)}
              required
            />
          </div>
          <.button type="submit" disabled={is_nil(@current_user.email_confirmed_at)}>
            Neues CLI-Token erstellen
          </.button>
        </form>

        <.table :if={@api_tokens != []} id="api-tokens-table" rows={@api_tokens}>
          <:col :let={token} label="Bezeichnung">
            <%= token.name %>
          </:col>
          <:col :let={token} label="Erstellt am" numeric={true}>
            <%= Calendar.strftime(token.inserted_at, "%d.%m.%Y %H:%M") %>
          </:col>
          <:col :let={token} label="Zuletzt genutzt" numeric={true}>
            <%= if token.last_used_at, do: Calendar.strftime(token.last_used_at, "%d.%m.%Y %H:%M"), else: "Noch nie" %>
          </:col>
          <:action :let={token}>
            <.button
              type="button"
              variant="secondary"
              phx-click="revoke_pat"
              phx-value-id={token.id}
            >
              Widerrufen
            </.button>
          </:action>
        </.table>
      </section>

      <%!-- Card 3: Danger Zone (60-Day Soft Delete) --%>
      <section class="bg-[var(--fq-color-bg-surface)] border-2 border-[var(--fq-status-danger)] rounded-lg p-6 space-y-4">
        <h2 class="text-base font-bold text-[#991B1B]">3. Gefahrenzone – Konto löschen (60-Tage-Soft-Delete)</h2>

        <div :if={@orphaned_orgs != []} class="p-4 rounded-md bg-[#FEF2F2] border border-[#EF4444] text-xs text-[#991B1B] space-y-1">
          <p class="font-semibold">
            Achtung: Sie sind der letzte Eigentümer der folgenden Organisationen:
            <span class="fq-mono">
              [<%= Enum.map_join(@orphaned_orgs, ", ", &("@" <> to_string(&1.handle))) %>]
            </span>.
          </p>
          <p>
            Diese Organisationen und alle zugehörigen Daten werden nach Ablauf der 60-tägigen Wiederherstellungsfrist ebenfalls unwiderruflich gelöscht.
          </p>
        </div>

        <form phx-change="update_delete_confirm" phx-submit="request_account_deletion" class="space-y-4 max-w-lg">
          <.input
            id="confirm-delete-handle"
            name="confirm_handle"
            label={"Bitte geben Sie zur Bestätigung Ihr Handle (#{@current_user.handle}) ein"}
            monospace={true}
            value={@delete_confirm_handle}
            placeholder={to_string(@current_user.handle)}
          />
          <.button
            type="submit"
            variant="danger"
            disabled={String.downcase(@delete_confirm_handle) != String.downcase(to_string(@current_user.handle))}
          >
            Konto zur Löschung vormerken (60 Tage Frist)
          </.button>
        </form>
      </section>
    </div>
    """
  end
end
