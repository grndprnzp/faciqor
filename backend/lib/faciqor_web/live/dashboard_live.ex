defmodule FaciqorWeb.DashboardLive do
  use FaciqorWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event("resend_verification_email", _params, socket) do
    {:noreply, put_flash(socket, :info, "Bestätigungs-E-Mail wurde erneut gesendet.")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
      <%!-- Left Column (GitHub Sidebar: User Context & Organization Quick List) --%>
      <aside id="dashboard-sidebar" class="lg:col-span-4 xl:col-span-3 space-y-5">
        <%!-- User Summary Card --%>
        <div class="bg-[var(--fq-color-bg-surface)] border border-[var(--fq-color-border)] rounded-lg p-4 space-y-3">
          <div class="flex items-center gap-3">
            <%= if user_avatar_url(@current_user) do %>
              <img
                src={user_avatar_url(@current_user)}
                alt="Avatar"
                class="w-12 h-12 rounded-full object-cover border border-[var(--fq-color-border-strong)] shrink-0"
              />
            <% else %>
              <div class="w-12 h-12 rounded-full bg-[var(--fq-color-bg-muted)] border border-[var(--fq-color-border-strong)] flex items-center justify-center text-sm font-bold text-[var(--fq-color-text-main)] shrink-0">
                <%= String.upcase(String.slice(@current_user.display_name || to_string(@current_user.handle) || "U", 0, 2)) %>
              </div>
            <% end %>
            <div class="min-w-0 flex-1">
              <div class="font-bold text-sm text-[var(--fq-color-text-main)] truncate">
                <%= @current_user.display_name || to_string(@current_user.email) %>
              </div>
              <div class="fq-mono text-xs text-[var(--fq-color-text-muted)] truncate">
                @<%= @current_user.handle %>
              </div>
            </div>
          </div>

          <div class="pt-2 border-t border-[var(--fq-color-border)] flex items-center justify-between text-xs">
            <span class="text-[var(--fq-color-text-muted)]">Konto-Status</span>
            <%= if @current_user.email_confirmed_at do %>
              <.status_badge status={:verified} />
            <% else %>
              <.status_badge status={:unverified} />
            <% end %>
          </div>

          <a
            href={~p"/settings/profile"}
            class="w-full inline-flex items-center justify-center rounded-md px-3 font-medium h-9 text-xs bg-[var(--fq-color-bg-surface)] text-[var(--fq-color-text-main)] border border-[var(--fq-color-border-strong)] hover:bg-[var(--fq-color-bg-muted)] transition-colors"
          >
            Profil &amp; CLI bearbeiten
          </a>
        </div>

        <%!-- Sidebar Organization Quick-Access Box --%>
        <.gh_box body_class="p-0">
          <:header>
            <span>Mandanten</span>
            <span class="px-1.5 py-0.5 rounded-full bg-[var(--fq-color-bg-surface)] border border-[var(--fq-color-border)] fq-mono tabular-nums text-[11px] text-[var(--fq-color-text-muted)]">
              <%= length(@user_orgs) %>
            </span>
          </:header>
          <:header_actions>
            <a
              href={~p"/orgs/new"}
              class="inline-flex items-center px-2 py-1 rounded text-xs font-semibold bg-[var(--fq-color-primary)] text-white hover:bg-[var(--fq-color-primary-hover)] transition-colors"
            >
              + Neu
            </a>
          </:header_actions>

          <%= if @user_orgs == [] do %>
            <div class="p-4 text-xs text-[var(--fq-color-text-muted)] space-y-2">
              <p>Noch keine Organisation vorhanden.</p>
              <a href={~p"/orgs/new"} class="font-medium text-[var(--fq-color-primary)] hover:underline inline-block">
                Erste Organisation anlegen &rarr;
              </a>
            </div>
          <% else %>
            <div class="divide-y divide-[var(--fq-color-border)]">
              <div
                :for={org <- @user_orgs}
                class="px-4 py-2.5 hover:bg-[var(--fq-color-bg-app)] transition-colors flex items-center justify-between gap-2"
              >
                <a
                  href={~p"/orgs/#{org.handle}/facilities"}
                  class="flex items-center gap-2.5 min-w-0 group"
                >
                  <span class="inline-flex items-center justify-center w-6 h-6 rounded bg-[var(--fq-color-primary-subtle)] text-[var(--fq-color-primary)] font-bold text-[10px] fq-mono shrink-0">
                    <%= String.upcase(String.slice(to_string(org.handle), 0, 2)) %>
                  </span>
                  <div class="min-w-0">
                    <div class="fq-mono font-semibold text-xs text-[var(--fq-color-text-main)] group-hover:text-[var(--fq-color-primary)] group-hover:underline truncate">
                      @<%= org.handle %>
                    </div>
                    <div :if={org.display_name} class="text-[11px] text-[var(--fq-color-text-muted)] truncate">
                      <%= org.display_name %>
                    </div>
                  </div>
                </a>
                <div class="flex items-center gap-1.5 shrink-0">
                  <.status_badge status={user_role_in_org(org, @current_user.id)} />
                  <a
                    href={~p"/orgs/#{org.handle}/settings"}
                    class="p-1 rounded text-[var(--fq-color-text-muted)] hover:text-[var(--fq-color-text-main)] hover:bg-[var(--fq-color-bg-muted)]"
                    title="Einstellungen"
                  >
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-3.5 h-3.5">
                      <path fill-rule="evenodd" d="M7.84 1.804A1 1 0 018.82 1h2.36a1 1 0 01.98.804l.331 1.652a6.993 6.993 0 011.929 1.115l1.598-.54a1 1 0 011.186.447l1.18 2.044a1 1 0 01-.205 1.251l-1.267 1.113a7.047 7.047 0 010 2.228l1.267 1.113a1 1 0 01.206 1.25l-1.18 2.045a1 1 0 01-1.187.447l-1.598-.54a6.993 6.993 0 01-1.929 1.115l-.33 1.652a1 1 0 01-.98.804H8.82a1 1 0 01-.98-.804l-.331-1.652a6.993 6.993 0 01-1.929-1.115l-1.598.54a1 1 0 01-1.186-.447l-1.18-2.044a1 1 0 01.205-1.251l1.267-1.114a7.05 7.05 0 010-2.227L1.821 7.773a1 1 0 01-.206-1.25l1.18-2.045a1 1 0 011.187-.447l1.598.54A6.993 6.993 0 017.51 3.456l.33-1.652zM10 13a3 3 0 100-6 3 3 0 000 6z" clip-rule="evenodd" />
                    </svg>
                  </a>
                </div>
              </div>
            </div>
          <% end %>
        </.gh_box>
      </aside>

      <%!-- Right Main Column (Overview, Onboarding Empty State or Organization Repository Table) --%>
      <div class="lg:col-span-8 xl:col-span-9 space-y-6">
        <.gh_subhead>
          <:title>Dashboard</:title>
          <:description>
            Willkommen im Faciqor Hub, <span class="fq-mono font-medium">@<%= @current_user.handle %></span>
          </:description>
          <:actions>
            <a
              href={~p"/orgs/new"}
              class="inline-flex items-center justify-center rounded-md px-4 font-medium h-11 lg:h-9 text-sm bg-[var(--fq-color-primary)] text-white hover:bg-[var(--fq-color-primary-hover)] transition-colors"
            >
              + Neue Organisation gründen
            </a>
          </:actions>
        </.gh_subhead>

        <%= if @user_orgs == [] do %>
          <%!-- Guided Empty State when user has 0 organizations --%>
          <div id="onboarding-empty-state" class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <%!-- Card 1 (Primary): Create First Organization --%>
            <.gh_box class="border-[var(--fq-color-border-strong)]" body_class="p-6 flex flex-col justify-between space-y-4 h-full">
              <:header>
                <span class="inline-block px-2 py-0.5 text-xs font-semibold rounded bg-[var(--fq-color-primary-subtle)] text-[var(--fq-color-primary)]">
                  Schritt 1 · Empfohlen
                </span>
              </:header>
              <div class="space-y-2">
                <h2 class="text-base font-bold text-[var(--fq-color-text-main)]">
                  Erste Organisation gründen
                </h2>
                <p class="text-sm text-[var(--fq-color-text-muted)]">
                  Legen Sie Ihren ersten Mandanten als Eigentümer/Bestandshalter, Hausverwaltung oder Dienstleister an.
                </p>
              </div>
              <div class="pt-2">
                <a
                  href={~p"/orgs/new"}
                  class="inline-flex items-center justify-center rounded-md px-4 font-medium h-11 lg:h-9 text-sm bg-[var(--fq-color-primary)] text-white hover:bg-[var(--fq-color-primary-hover)]"
                >
                  Erste Organisation gründen
                </a>
              </div>
            </.gh_box>

            <%!-- Card 2 (Secondary): Setup Profile & CLI --%>
            <.gh_box body_class="p-6 flex flex-col justify-between space-y-4 h-full">
              <:header>
                <span class="inline-block px-2 py-0.5 text-xs font-semibold rounded bg-[var(--fq-color-bg-surface)] border border-[var(--fq-color-border)] text-[var(--fq-color-text-muted)]">
                  Schritt 2 · Optional
                </span>
              </:header>
              <div class="space-y-2">
                <h2 class="text-base font-bold text-[var(--fq-color-text-main)]">
                  Benutzerprofil &amp; CLI einrichten
                </h2>
                <p class="text-sm text-[var(--fq-color-text-muted)]">
                  Passen Sie Ihr automatisch generiertes Handle (<span class="fq-mono">@<%= @current_user.handle %></span>) an oder erstellen Sie ein Personal Access Token für die Go-CLI.
                </p>
              </div>
              <div class="pt-2">
                <a
                  href={~p"/settings/profile"}
                  class="inline-flex items-center justify-center rounded-md px-4 font-medium h-11 lg:h-9 text-sm bg-[var(--fq-color-bg-surface)] text-[var(--fq-color-text-main)] border border-[var(--fq-color-border-strong)] hover:bg-[var(--fq-color-bg-muted)]"
                >
                  Benutzerprofil &amp; CLI einrichten
                </a>
              </div>
            </.gh_box>
          </div>
        <% else %>
          <%!-- Organization Overview Table in GitHub Box style --%>
          <div class="space-y-3">
            <.table id="organizations-table" rows={@user_orgs}>
              <:header_bar>
                <div class="flex items-center gap-2 font-semibold text-[var(--fq-color-text-main)]">
                  <span>Ihre Organisationen</span>
                  <span class="px-2 py-0.5 rounded-full bg-[var(--fq-color-bg-surface)] border border-[var(--fq-color-border)] fq-mono tabular-nums text-[11px] text-[var(--fq-color-text-muted)]">
                    <%= length(@user_orgs) %>
                  </span>
                </div>
                <span class="text-[var(--fq-color-text-muted)]">
                  Aktiver Mandant: <strong class="fq-mono text-[var(--fq-color-text-main)]">@<%= List.first(@user_orgs).handle %></strong>
                </span>
              </:header_bar>
              <:col :let={org} label="Handle">
                <a
                  href={~p"/orgs/#{org.handle}/facilities"}
                  class="fq-mono font-semibold text-[var(--fq-color-primary)] hover:underline"
                >
                  @<%= org.handle %>
                </a>
              </:col>
              <:col :let={org} label="Anzeigename / Firma">
                <span class="font-medium"><%= org.display_name || org.legal_name || "—" %></span>
              </:col>
              <:col :let={org} label="Schwerpunkt">
                <span class="text-xs text-[var(--fq-color-text-muted)]"><%= focus_label(org.primary_focus) %></span>
              </:col>
              <:col :let={org} label="Meine Rolle">
                <.status_badge status={user_role_in_org(org, @current_user.id)} />
              </:col>
              <:action :let={org}>
                <div class="flex items-center justify-end gap-3">
                  <a
                    href={~p"/orgs/#{org.handle}/facilities"}
                    class="inline-flex items-center px-2.5 py-1 rounded border border-[var(--fq-color-border-strong)] bg-[var(--fq-color-bg-surface)] hover:bg-[var(--fq-color-bg-muted)] text-xs font-semibold text-[var(--fq-color-primary)] transition-colors"
                  >
                    Objekte
                  </a>
                  <a
                    href={~p"/orgs/#{org.handle}/settings"}
                    class="text-xs font-medium text-[var(--fq-color-text-muted)] hover:text-[var(--fq-color-text-main)] hover:underline"
                  >
                    Einstellungen
                  </a>
                </div>
              </:action>
            </.table>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp user_avatar_url(%{avatar_blob: %{variants: %{"128" => key}}}) when is_binary(key),
    do: Faciqor.Media.Storage.public_url(key)

  defp user_avatar_url(%{avatar_blob: %{variants: %{"64" => key}}}) when is_binary(key),
    do: Faciqor.Media.Storage.public_url(key)

  defp user_avatar_url(%{avatar_blob: %{key: key}}) when is_binary(key),
    do: Faciqor.Media.Storage.public_url(key)

  defp user_avatar_url(_), do: nil

  defp focus_label(:property_owner), do: "Eigentümer / Bestandshalter"
  defp focus_label(:property_manager), do: "Hausverwaltung"
  defp focus_label(:service_provider), do: "Dienstleister / KMU"
  defp focus_label(_), do: "—"

  defp user_role_in_org(%{memberships: memberships}, user_id) when is_list(memberships) do
    case Enum.find(memberships, &(&1.user_id == user_id)) do
      %{role: role} -> role
      _ -> :member
    end
  end

  defp user_role_in_org(_, _), do: :member
end
