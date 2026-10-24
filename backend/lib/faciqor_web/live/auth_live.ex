defmodule FaciqorWeb.AuthLive do
  use FaciqorWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:active_tab, :magic_link)
     |> assign(:email, "")
     |> assign(:password, "")
     |> assign(:magic_link_sent, false)
     |> assign(:dev_magic_link, nil)}
  end

  @impl true
  def handle_params(%{"email" => email}, _uri, socket) when email != "" do
    email = String.trim(email)
    Phoenix.PubSub.subscribe(Faciqor.PubSub, "dev:magic_link:#{email}")

    case Faciqor.Accounts.User
         |> Ash.Query.for_read(:request_magic_link, %{email: email})
         |> Ash.read(authorize?: false) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign(:email, email)
         |> assign(:magic_link_sent, true)
         |> put_flash(:info, "Einmal-Anmeldelink wurde an #{email} gesendet.")}

      {:error, _error} ->
        {:noreply,
         socket
         |> assign(:email, email)
         |> put_flash(:error, "Fehler beim Anfordern des Anmeldelinks. Bitte Eingabe prüfen.")}
    end
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("switch_tab", %{"tab" => "magic_link"}, socket) do
    {:noreply, assign(socket, :active_tab, :magic_link)}
  end

  def handle_event("switch_tab", %{"tab" => "password"}, socket) do
    {:noreply, assign(socket, :active_tab, :password)}
  end

  def handle_event("send_magic_link", %{"email" => email}, socket) do
    email = String.trim(email)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Faciqor.PubSub, "dev:magic_link:#{email}")
    end

    case Faciqor.Accounts.User
         |> Ash.Query.for_read(:request_magic_link, %{email: email})
         |> Ash.read(authorize?: false) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign(:email, email)
         |> assign(:magic_link_sent, true)
         |> put_flash(:info, "Einmal-Anmeldelink wurde an #{email} gesendet.")}

      {:error, _error} ->
        {:noreply,
         socket
         |> put_flash(:error, "Fehler beim Anfordern des Anmeldelinks. Bitte Eingabe prüfen.")}
    end
  end

  @impl true
  def handle_info({:magic_link_generated, _email, url}, socket) do
    {:noreply, assign(socket, :dev_magic_link, url)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-[80vh] flex items-center justify-center">
      <div class="w-full max-w-md bg-[var(--fq-color-bg-surface)] border border-[var(--fq-color-border)] rounded-lg p-6 shadow-sm space-y-6">
        <div class="text-center space-y-1">
          <h1 class="text-xl font-bold text-[var(--fq-color-text-main)]">
            <%= if @live_action == :register, do: "Bei Faciqor registrieren", else: "Bei Faciqor anmelden" %>
          </h1>
          <p class="text-xs text-[var(--fq-color-text-muted)]">
            ERP &amp; Nachweisplattform für Immobilienverwaltung und Objektbetreuung
          </p>
        </div>

        <%!-- Primary Action: Google OAuth2 --%>
        <div>
          <a
            href="/auth/user/google"
            class="w-full h-11 lg:h-9 inline-flex items-center justify-center gap-2 rounded-md border border-[var(--fq-color-border-strong)] bg-[var(--fq-color-bg-surface)] px-4 text-sm font-medium text-[var(--fq-color-text-main)] hover:bg-[var(--fq-color-bg-muted)] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#2563EB]"
          >
            <span>Weiter mit Google</span>
          </a>
        </div>

        <div class="relative flex py-1 items-center">
          <div class="flex-grow border-t border-[var(--fq-color-border)]"></div>
          <span class="flex-shrink mx-3 text-xs text-[var(--fq-color-text-muted)]">oder per E-Mail</span>
          <div class="flex-grow border-t border-[var(--fq-color-border)]"></div>
        </div>

        <%!-- Tabs: Magic Link (Recommended) vs Password --%>
        <div class="grid grid-cols-2 gap-1 p-1 rounded-md bg-[var(--fq-color-bg-muted)]" role="tablist">
          <button
            type="button"
            role="tab"
            phx-click="switch_tab"
            phx-value-tab="magic_link"
            class={[
              "py-1.5 text-xs font-medium rounded transition-colors",
              if(@active_tab == :magic_link,
                do: "bg-[var(--fq-color-bg-surface)] text-[var(--fq-color-text-main)] shadow-sm",
                else: "text-[var(--fq-color-text-muted)] hover:text-[var(--fq-color-text-main)]"
              )
            ]}
          >
            Magic Link (Empfohlen)
          </button>
          <button
            type="button"
            role="tab"
            phx-click="switch_tab"
            phx-value-tab="password"
            class={[
              "py-1.5 text-xs font-medium rounded transition-colors",
              if(@active_tab == :password,
                do: "bg-[var(--fq-color-bg-surface)] text-[var(--fq-color-text-main)] shadow-sm",
                else: "text-[var(--fq-color-text-muted)] hover:text-[var(--fq-color-text-main)]"
              )
            ]}
          >
            Passwort
          </button>
        </div>

        <%= if @active_tab == :magic_link do %>
          <form phx-submit="send_magic_link" class="space-y-4">
            <.input
              id="magic-link-email"
              name="email"
              type="email"
              label="E-Mail-Adresse"
              value={@email}
              placeholder="name@firma.de"
              required
            />
            <.button type="submit" class="w-full">
              Einmal-Anmeldelink senden
            </.button>
          </form>

          <div :if={@dev_magic_link} id="dev-magic-link-banner" class="p-3 rounded-md bg-[#EFF6FF] border border-[#BFDBFE] space-y-2">
            <div class="flex items-center gap-1.5 text-xs font-semibold text-[#1E40AF]">
              <span>🚀 [Entwicklungsmodus] Anmeldelink generiert</span>
            </div>
            <p class="text-xs text-[#1E3A8A]">
              Direkt im Browser anmelden ohne E-Mail-Postfach (auch im Terminal geloggt):
            </p>
            <a
              href={@dev_magic_link}
              class="flex items-center justify-center w-full h-11 lg:h-9 rounded-md bg-[var(--fq-color-primary)] text-white text-xs font-medium hover:bg-[var(--fq-color-primary-hover)] transition-colors shadow-sm"
            >
              Jetzt direkt als <%= @email %> anmelden &rarr;
            </a>
          </div>
        <% else %>
          <form method="post" action={if @live_action == :register, do: "/auth/user/password/register", else: "/auth/user/password/sign_in"} class="space-y-4">
            <input type="hidden" name="_csrf_token" value={Phoenix.Controller.get_csrf_token()} />
            <.input
              id="password-email"
              name="user[email]"
              type="email"
              label="E-Mail-Adresse"
              value={@email}
              placeholder="name@firma.de"
              required
            />
            <.input
              id="password-input"
              name="user[password]"
              type="password"
              label="Passwort (min. 12 Zeichen)"
              value={@password}
              minlength="12"
              required
            />
            <.button type="submit" class="w-full">
              <%= if @live_action == :register, do: "Konto erstellen", else: "Mit Passwort anmelden" %>
            </.button>
          </form>
        <% end %>
      </div>
    </div>
    """
  end
end
