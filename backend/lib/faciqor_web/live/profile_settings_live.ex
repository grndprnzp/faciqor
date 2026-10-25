defmodule FaciqorWeb.ProfileSettingsLive do
  use FaciqorWeb, :live_view
  require Ash.Query

  alias Faciqor.Accounts

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    user = Ash.load!(user, [:identities], actor: user)

    tokens = load_tokens(user)
    orphaned_orgs = Accounts.list_orphaned_organizations_for_user(user.id)
    user_orgs = load_user_orgs(user)

    profile_form =
      user
      |> AshPhoenix.Form.for_update(:update_profile, actor: user, as: "user")
      |> to_form()

    password_action = if user.hashed_password, do: :change_password, else: :set_initial_password

    password_form =
      user
      |> AshPhoenix.Form.for_update(password_action, actor: user, as: "password")
      |> to_form()

    email_change_form =
      user
      |> AshPhoenix.Form.for_update(:request_email_change, actor: user, as: "email_change")
      |> to_form()

    has_google = Enum.any?(user.identities || [], &(&1.strategy == "google"))

    {:ok,
     socket
     |> assign(:current_user, user)
     |> assign(:profile_form, profile_form)
     |> assign(:password_form, password_form)
     |> assign(:email_change_form, email_change_form)
     |> assign(:api_tokens, tokens)
     |> assign(:new_token_name, "")
     |> assign(:new_token_expiry_days, "365")
     |> assign(:new_token_scope, "all")
     |> assign(:newly_created_plain_token, nil)
     |> assign(:orphaned_orgs, orphaned_orgs)
     |> assign(:user_orgs, user_orgs)
     |> assign(:has_google_identity, has_google)
     |> assign(:show_email_change_form, false)
     |> assign(:delete_confirm_handle, "")}
  end

  @impl true
  def handle_event("resend_verification_email", _params, socket) do
    {:noreply, put_flash(socket, :info, "Bestätigungs-E-Mail wurde erneut gesendet.")}
  end

  def handle_event("validate_profile", %{"user" => params}, socket) do
    params = normalize_user_params(params)
    form = AshPhoenix.Form.validate(socket.assigns.profile_form.source, params)
    {:noreply, assign(socket, :profile_form, to_form(form))}
  end

  def handle_event("save_profile", %{"user" => params}, socket) do
    params = normalize_user_params(params)

    case AshPhoenix.Form.submit(socket.assigns.profile_form.source, params: params) do
      {:ok, updated_user} ->
        new_form =
          updated_user
          |> AshPhoenix.Form.for_update(:update_profile, actor: updated_user, as: "user")
          |> to_form()

        {:noreply,
         socket
         |> assign(:current_user, updated_user)
         |> assign(:profile_form, new_form)
         |> put_flash(:info, "Benutzerprofil erfolgreich aktualisiert.")}

      {:error, form} ->
        {:noreply,
         socket
         |> assign(:profile_form, to_form(form))
         |> put_flash(:error, "Profil konnte nicht gespeichert werden.")}
    end
  end

  def handle_event("validate_password", %{"password" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.password_form.source, params)
    {:noreply, assign(socket, :password_form, to_form(form))}
  end

  def handle_event("change_password", %{"password" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.password_form.source, params: params) do
      {:ok, updated_user} ->
        new_form =
          updated_user
          |> AshPhoenix.Form.for_update(:change_password, actor: updated_user, as: "password")
          |> to_form()

        {:noreply,
         socket
         |> assign(:current_user, updated_user)
         |> assign(:password_form, new_form)
         |> put_flash(:info, "Kennwort erfolgreich aktualisiert.")}

      {:error, form} ->
        {:noreply,
         socket
         |> assign(:password_form, to_form(form))
         |> put_flash(:error, "Kennwort konnte nicht aktualisiert werden.")}
    end
  end

  def handle_event("toggle_email_change", _params, socket) do
    {:noreply, assign(socket, :show_email_change_form, not socket.assigns.show_email_change_form)}
  end

  def handle_event("request_email_change", %{"email_change" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.email_change_form.source, params: params) do
      {:ok, updated_user} ->
        new_form =
          updated_user
          |> AshPhoenix.Form.for_update(:request_email_change, actor: updated_user, as: "email_change")
          |> to_form()

        {:noreply,
         socket
         |> assign(:current_user, updated_user)
         |> assign(:email_change_form, new_form)
         |> assign(:show_email_change_form, false)
         |> put_flash(:info, "Bestätigungs-Anfrage an #{updated_user.pending_email} vorgemerkt.")}

      {:error, form} ->
        {:noreply, assign(socket, :email_change_form, to_form(form))}
    end
  end

  def handle_event("confirm_email_change", _params, socket) do
    user = socket.assigns.current_user

    case user
         |> Ash.Changeset.for_update(:confirm_email_change, %{})
         |> Ash.update(actor: user) do
      {:ok, updated_user} ->
        {:noreply,
         socket
         |> assign(:current_user, updated_user)
         |> put_flash(:info, "E-Mail-Adresse erfolgreich auf #{updated_user.email} aktualisiert.")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Fehler bei der Bestätigung der E-Mail-Adresse.")}
    end
  end

  def handle_event("cancel_email_change", _params, socket) do
    user = socket.assigns.current_user

    case user
         |> Ash.Changeset.for_update(:cancel_email_change, %{})
         |> Ash.update(actor: user) do
      {:ok, updated_user} ->
        {:noreply,
         socket
         |> assign(:current_user, updated_user)
         |> put_flash(:info, "E-Mail-Änderungsanfrage abgebrochen.")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Konnte Anfrage nicht abbrechen.")}
    end
  end

  def handle_event("create_pat", params, socket) do
    user = socket.assigns.current_user
    name = String.trim(params["name"] || "")

    if name == "" do
      {:noreply, put_flash(socket, :error, "Bitte geben Sie eine Token-Bezeichnung an.")}
    else
      expires_in_days =
        case params["expires_in_days"] do
          "30" -> 30
          "90" -> 90
          "180" -> 180
          "365" -> 365
          "0" -> 0
          _ -> 365
        end

      scopes = params["scopes"] || "all"

      case Accounts.create_personal_access_token(name,
             actor: user,
             expires_in_days: expires_in_days,
             scopes: scopes
           ) do
        {:ok, plain_token, _record} ->
          {:noreply,
           socket
           |> assign(:newly_created_plain_token, plain_token)
           |> assign(:new_token_name, "")
           |> assign(:api_tokens, load_tokens(user))
           |> put_flash(:info, "Neues Personal Access Token wurde erstellt.")}

        {:error, _err} ->
          {:noreply, put_flash(socket, :error, "Token-Erstellung fehlgeschlagen (E-Mail-Verifizierung erforderlich).")}
      end
    end
  end

  def handle_event("revoke_pat", %{"id" => token_id}, socket) do
    user = socket.assigns.current_user

    case Accounts.ApiToken
         |> Ash.Query.filter(id == ^token_id and user_id == ^user.id)
         |> Ash.read_one(actor: user) do
      {:ok, %Accounts.ApiToken{} = token} ->
        _ = token |> Ash.Changeset.for_update(:revoke, %{}) |> Ash.update(actor: user)
        {:noreply, assign(socket, :api_tokens, load_tokens(user))}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("update_delete_confirm", %{"confirm_handle" => val}, socket) do
    {:noreply, assign(socket, :delete_confirm_handle, val)}
  end

  def handle_event("request_account_deletion", _params, socket) do
    user = socket.assigns.current_user

    if String.downcase(String.trim(socket.assigns.delete_confirm_handle)) ==
         String.downcase(to_string(user.handle)) do
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

  defp normalize_user_params(%{"handle" => handle} = params) when is_binary(handle) do
    cleaned =
      handle
      |> String.trim()
      |> String.trim_leading("@")
      |> String.downcase()

    Map.put(params, "handle", cleaned)
  end

  defp normalize_user_params(params), do: params

  defp load_tokens(user) do
    Accounts.ApiToken
    |> Ash.Query.filter(user_id == ^user.id and is_nil(revoked_at))
    |> Ash.Query.sort(inserted_at: :desc)
    |> Ash.read!(actor: user)
  end

  defp load_user_orgs(user) do
    Accounts.Organization
    |> Ash.Query.filter(is_nil(deleted_at))
    |> Ash.Query.load(:memberships)
    |> Ash.read!(actor: user)
  end

  defp token_expired?(%Accounts.ApiToken{expires_at: nil}), do: false
  defp token_expired?(%Accounts.ApiToken{expires_at: expires_at}) do
    DateTime.compare(expires_at, DateTime.utc_now()) == :lt
  end

  defp org_role(%Accounts.Organization{memberships: memberships}, user_id) when is_list(memberships) do
    case Enum.find(memberships, &(&1.user_id == user_id)) do
      %{role: role} when role in [:owner, :member, :guest] -> role
      _ -> :member
    end
  end

  defp org_role(_, _), do: :member

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div>
        <h1 class="text-2xl font-bold text-[var(--fq-color-text-main)]">Benutzerprofil &amp; Sicherheit</h1>
        <p class="text-sm text-[var(--fq-color-text-muted)]">
          Verwalten Sie Ihre persönlichen Stammdaten, Anmeldedaten, CLI-Zugangstokens und Mandanten.
        </p>
      </div>

      <%!-- Card 1: User Profile & Stammdaten --%>
      <section class="bg-[var(--fq-color-bg-surface)] border border-[var(--fq-color-border)] rounded-lg p-6 space-y-4">
        <div>
          <h2 class="text-base font-bold text-[var(--fq-color-text-main)]">1. Persönliche Stammdaten</h2>
          <p class="text-xs text-[var(--fq-color-text-muted)]">
            Diese Daten werden in Auftragsberichten, Revisionsprotokollen und zur Identifikation im Hub verwendet.
          </p>
        </div>

        <.form :let={f} for={@profile_form} id="profile-form" phx-change="validate_profile" phx-submit="save_profile" class="space-y-4 max-w-2xl">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <.input
              field={f[:handle]}
              label="Benutzer-Handle"
              prefix="@"
              monospace={true}
              phx-debounce="300"
              required
            />
            <.input
              field={f[:display_name]}
              label="Anzeigename (z. B. Max Mustermann)"
              placeholder="Vollständiger Name"
            />
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <.input
              field={f[:first_name]}
              label="Vorname"
              placeholder="Vorname"
            />
            <.input
              field={f[:last_name]}
              label="Nachname"
              placeholder="Nachname"
            />
          </div>

          <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <.input
              field={f[:phone]}
              label="Telefon (Rückfragen)"
              placeholder="+49 170 1234567"
            />
            <div class="space-y-1">
              <label class="block text-sm font-medium text-[var(--fq-color-text-main)]">Zeitzone</label>
              <select
                name="user[timezone]"
                class="block w-full h-11 lg:h-9 px-3 text-sm border rounded-md bg-[var(--fq-color-bg-surface)] text-[var(--fq-color-text-main)] border-[var(--fq-color-border-strong)]"
              >
                <option value="Europe/Berlin" selected={f[:timezone].value == "Europe/Berlin"}>Europe/Berlin (MEZ/MESZ)</option>
                <option value="Europe/Vienna" selected={f[:timezone].value == "Europe/Vienna"}>Europe/Vienna</option>
                <option value="Europe/Zurich" selected={f[:timezone].value == "Europe/Zurich"}>Europe/Zurich</option>
                <option value="UTC" selected={f[:timezone].value == "UTC"}>UTC</option>
              </select>
            </div>
            <div class="space-y-1">
              <label class="block text-sm font-medium text-[var(--fq-color-text-main)]">Sprache</label>
              <select
                name="user[locale]"
                class="block w-full h-11 lg:h-9 px-3 text-sm border rounded-md bg-[var(--fq-color-bg-surface)] text-[var(--fq-color-text-main)] border-[var(--fq-color-border-strong)]"
              >
                <option value="de" selected={f[:locale].value == "de"}>Deutsch (DE)</option>
                <option value="en" selected={f[:locale].value == "en"}>English (EN)</option>
              </select>
            </div>
          </div>

          <.button type="submit">
            Profil speichern
          </.button>
        </.form>
      </section>

      <%!-- Card 2: E-Mail & Verifizierung --%>
      <section class="bg-[var(--fq-color-bg-surface)] border border-[var(--fq-color-border)] rounded-lg p-6 space-y-4">
        <div>
          <h2 class="text-base font-bold text-[var(--fq-color-text-main)]">2. Primäre E-Mail-Adresse</h2>
          <p class="text-xs text-[var(--fq-color-text-muted)]">
            Ihre E-Mail dient als primärer Anmeldeanker und für wichtige Systembenachrichtigungen.
          </p>
        </div>

        <div class="max-w-lg space-y-3">
          <div class="flex items-center justify-between">
            <span class="text-sm font-medium text-[var(--fq-color-text-main)]">Aktuelle Adresse</span>
            <%= if @current_user.email_confirmed_at do %>
              <.status_badge status={:verified} />
            <% else %>
              <.status_badge status={:unverified} />
            <% end %>
          </div>
          <.input
            id="profile-email-display"
            name="email_display"
            type="email"
            value={to_string(@current_user.email)}
            readonly={true}
          />

          <%= if @current_user.pending_email do %>
            <div class="p-4 rounded-md bg-[#FFFBEB] border border-[#F59E0B] space-y-2">
              <div class="flex items-center justify-between text-xs text-[#92400E]">
                <span>Ausstehende Änderung auf: <strong class="fq-mono"><%= @current_user.pending_email %></strong></span>
                <span class="font-semibold">Wartet auf Bestätigung</span>
              </div>
              <div class="flex items-center gap-2 pt-1">
                <.button type="button" phx-click="confirm_email_change">
                  Jetzt bestätigen (Verifizieren)
                </.button>
                <.button type="button" variant="secondary" phx-click="cancel_email_change">
                  Abbrechen
                </.button>
              </div>
            </div>
          <% else %>
            <div>
              <%= if @show_email_change_form do %>
                <.form :let={ef} for={@email_change_form} id="email-change-form" phx-submit="request_email_change" class="space-y-3 pt-2">
                  <.input
                    field={ef[:new_email]}
                    type="email"
                    label="Neue E-Mail-Adresse"
                    placeholder="neue-adresse@example.com"
                    required
                  />
                  <div class="flex items-center gap-2">
                    <.button type="submit">
                      Änderungslink anfordern
                    </.button>
                    <.button type="button" variant="ghost" phx-click="toggle_email_change">
                      Abbrechen
                    </.button>
                  </div>
                </.form>
              <% else %>
                <.button type="button" variant="secondary" phx-click="toggle_email_change">
                  E-Mail-Adresse ändern
                </.button>
              <% end %>
            </div>
          <% end %>
        </div>
      </section>

      <%!-- Card 3: Kennwort & Authentifizierung --%>
      <section class="bg-[var(--fq-color-bg-surface)] border border-[var(--fq-color-border)] rounded-lg p-6 space-y-4">
        <div>
          <h2 class="text-base font-bold text-[var(--fq-color-text-main)]">3. Kennwort &amp; Sicherheit</h2>
          <p class="text-xs text-[var(--fq-color-text-muted)]">
            <%= if @current_user.hashed_password do %>
              Ändern Sie Ihr persönliches Passwort für den direkten Web-Login.
            <% else %>
              Sie haben sich bisher passwortlos angemeldet. Hier können Sie ein Kennwort festlegen.
            <% end %>
          </p>
        </div>

        <.form :let={pf} for={@password_form} id="password-form" phx-change="validate_password" phx-submit="change_password" class="space-y-4 max-w-lg">
          <div :if={@current_user.hashed_password}>
            <.input
              field={pf[:current_password]}
              type="password"
              label="Aktuelles Passwort"
              required
            />
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <.input
              field={pf[:password]}
              type="password"
              label="Neues Passwort (min. 8 Zeichen)"
              required
            />
            <.input
              field={pf[:password_confirmation]}
              type="password"
              label="Passwort bestätigen"
              required
            />
          </div>

          <.button type="submit">
            <%= if @current_user.hashed_password, do: "Kennwort aktualisieren", else: "Kennwort festlegen" %>
          </.button>
        </.form>
      </section>

      <%!-- Card 4: Verknüpfte Konten (SSO) --%>
      <section class="bg-[var(--fq-color-bg-surface)] border border-[var(--fq-color-border)] rounded-lg p-6 space-y-4">
        <div>
          <h2 class="text-base font-bold text-[var(--fq-color-text-main)]">4. Verknüpfte Anmeldedienste (SSO)</h2>
          <p class="text-xs text-[var(--fq-color-text-muted)]">
            Übersicht über verbundene Drittanbieter-Identitäten zur schnellen Anmeldung.
          </p>
        </div>

        <div class="divide-y divide-[var(--fq-color-border)] max-w-lg">
          <div class="py-3 flex items-center justify-between">
            <div class="flex items-center gap-3">
              <span class="font-medium text-sm text-[var(--fq-color-text-main)]">Google Workspace / Google Konto</span>
            </div>
            <%= if @has_google_identity do %>
              <.status_badge status={:verified} />
            <% else %>
              <span class="text-xs text-[var(--fq-color-text-muted)] italic">Nicht verknüpft</span>
            <% end %>
          </div>
        </div>
      </section>

      <%!-- Card 5: Personal Access Tokens (Go-CLI & gRPC) --%>
      <section class="bg-[var(--fq-color-bg-surface)] border border-[var(--fq-color-border)] rounded-lg p-6 space-y-4">
        <div>
          <h2 class="text-base font-bold text-[var(--fq-color-text-main)]">5. Personal Access Tokens (Go-CLI &amp; gRPC)</h2>
          <p class="text-xs text-[var(--fq-color-text-muted)]">
            Token für den authentifizierten Zugriff über die <span class="fq-mono">faciqor</span> Standalone-CLI und gRPC-Endpunkte.
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
          <div class="flex items-center gap-2">
            <div class="flex-1 p-2 rounded bg-white border border-[#6EE7B7] fq-mono text-xs select-all overflow-x-auto">
              <%= @newly_created_plain_token %>
            </div>
            <button
              type="button"
              id="copy-token-btn"
              phx-hook="CopyToClipboard"
              data-clipboard-text={@newly_created_plain_token}
              class="px-3 py-2 text-xs font-medium rounded bg-[#065F46] text-white hover:bg-[#044E39] transition-colors"
            >
              Kopieren
            </button>
          </div>
          <p class="text-xs text-[#065F46] pt-1">CLI-Anmeldebefehl:</p>
          <div class="flex items-center gap-2">
            <code class="flex-1 block p-2 rounded bg-white border border-[#6EE7B7] fq-mono text-xs select-all overflow-x-auto">
              faciqor auth login --token <%= @newly_created_plain_token %>
            </code>
            <button
              type="button"
              id="copy-cli-btn"
              phx-hook="CopyToClipboard"
              data-clipboard-text={"faciqor auth login --token " <> @newly_created_plain_token}
              class="px-3 py-2 text-xs font-medium rounded bg-[#065F46] text-white hover:bg-[#044E39] transition-colors"
            >
              Kopieren
            </button>
          </div>
        </div>

        <form id="pat-form" phx-submit="create_pat" class="space-y-3 max-w-3xl">
          <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-3 items-end">
            <div>
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
            <div>
              <label class="block text-sm font-medium text-[var(--fq-color-text-main)] mb-1">Berechtigung</label>
              <select
                name="scopes"
                disabled={is_nil(@current_user.email_confirmed_at)}
                class="block w-full h-11 lg:h-9 px-3 text-sm border rounded-md bg-[var(--fq-color-bg-surface)] text-[var(--fq-color-text-main)] border-[var(--fq-color-border-strong)]"
              >
                <option value="all" selected>Vollzugriff (all)</option>
                <option value="read_only">Nur Leserechte (read_only)</option>
                <option value="cli">CLI &amp; Operationen (cli)</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-[var(--fq-color-text-main)] mb-1">Gültigkeit</label>
              <select
                name="expires_in_days"
                disabled={is_nil(@current_user.email_confirmed_at)}
                class="block w-full h-11 lg:h-9 px-3 text-sm border rounded-md bg-[var(--fq-color-bg-surface)] text-[var(--fq-color-text-main)] border-[var(--fq-color-border-strong)]"
              >
                <option value="30">30 Tage</option>
                <option value="90">90 Tage</option>
                <option value="180">180 Tage</option>
                <option value="365" selected>1 Jahr (365 Tage)</option>
                <option value="0">Kein Ablaufdatum</option>
              </select>
            </div>
            <div>
              <.button type="submit" disabled={is_nil(@current_user.email_confirmed_at)} class="w-full">
                Token erstellen
              </.button>
            </div>
          </div>
        </form>

        <.table :if={@api_tokens != []} id="api-tokens-table" rows={@api_tokens}>
          <:col :let={token} label="Bezeichnung">
            <div class="font-medium"><%= token.name %></div>
            <div class="text-xs fq-mono text-[var(--fq-color-text-muted)]">
              <%= token.token_prefix || "fq_pat_..." %>****
            </div>
          </:col>
          <:col :let={token} label="Erstellt am" numeric={true}>
            <%= Calendar.strftime(token.inserted_at, "%d.%m.%Y %H:%M") %>
          </:col>
          <:col :let={token} label="Gültig bis" numeric={true}>
            <%= if token.expires_at, do: Calendar.strftime(token.expires_at, "%d.%m.%Y"), else: "Unbegrenzt" %>
          </:col>
          <:col :let={token} label="Zuletzt genutzt" numeric={true}>
            <%= if token.last_used_at, do: Calendar.strftime(token.last_used_at, "%d.%m.%Y %H:%M"), else: "Noch nie" %>
          </:col>
          <:col :let={token} label="Status">
            <%= if token_expired?(token) do %>
              <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-[#FFFBEB] text-[#92400E]">
                Abgelaufen
              </span>
            <% else %>
              <.status_badge status={:verified} />
            <% end %>
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

      <%!-- Card 6: Meine Organisationen & Rollen --%>
      <section class="bg-[var(--fq-color-bg-surface)] border border-[var(--fq-color-border)] rounded-lg p-6 space-y-4">
        <div>
          <h2 class="text-base font-bold text-[var(--fq-color-text-main)]">6. Meine Mandanten &amp; Mitgliedschaften</h2>
          <p class="text-xs text-[var(--fq-color-text-muted)]">
            Übersicht aller Organisationen, zu denen Ihr Benutzerkonto Zugang hat.
          </p>
        </div>

        <%= if @user_orgs == [] do %>
          <p class="text-xs italic text-[var(--fq-color-text-muted)]">
            Sie sind derzeit noch keiner Organisation zugeordnet.
          </p>
        <% else %>
          <div class="divide-y divide-[var(--fq-color-border)]">
            <div :for={org <- @user_orgs} class="py-3 flex items-center justify-between">
              <div>
                <div class="font-medium text-sm text-[var(--fq-color-text-main)] flex items-center gap-2">
                  <span class="fq-mono font-semibold">@<%= org.handle %></span>
                  <span :if={org.display_name} class="text-[var(--fq-color-text-muted)] text-xs">
                    (<%= org.display_name %>)
                  </span>
                </div>
                <div class="text-xs text-[var(--fq-color-text-muted)]">
                  Fokus: <%= org.primary_focus %>
                </div>
              </div>
              <div class="flex items-center gap-3">
                <.status_badge status={org_role(org, @current_user.id)} />
                <a
                  href={~p"/orgs/#{org.handle}/settings"}
                  class="text-xs font-medium text-[var(--fq-color-primary)] hover:underline"
                >
                  Einstellungen &rarr;
                </a>
              </div>
            </div>
          </div>
        <% end %>
      </section>

      <%!-- Card 7: Danger Zone (60-Day Soft Delete) --%>
      <section class="bg-[var(--fq-color-bg-surface)] border-2 border-[var(--fq-status-danger)] rounded-lg p-6 space-y-4">
        <h2 class="text-base font-bold text-[#991B1B]">7. Gefahrenzone – Konto löschen (60-Tage-Soft-Delete)</h2>

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

        <form id="delete-account-form" phx-change="update_delete_confirm" phx-submit="request_account_deletion" class="space-y-4 max-w-lg">
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
            disabled={String.downcase(String.trim(@delete_confirm_handle)) != String.downcase(to_string(@current_user.handle))}
          >
            Konto zur Löschung vormerken (60 Tage Frist)
          </.button>
        </form>
      </section>
    </div>
    """
  end
end
