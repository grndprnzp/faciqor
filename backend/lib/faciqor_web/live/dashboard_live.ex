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
    <div class="space-y-6">
      <div class="flex items-center justify-between">
        <div>
          <h1 class="text-2xl font-bold text-[var(--fq-color-text-main)]">Dashboard</h1>
          <p class="text-sm text-[var(--fq-color-text-muted)]">
            Willkommen im Faciqor Hub, <span class="fq-mono font-medium">@<%= @current_user.handle %></span>
          </p>
        </div>
      </div>

      <%= if @user_orgs == [] do %>
        <%!-- Guided Empty State when user has 0 organizations --%>
        <div id="onboarding-empty-state" class="grid grid-cols-1 md:grid-cols-2 gap-6 pt-4">
          <%!-- Card 1 (Primary): Create First Organization --%>
          <div class="bg-[var(--fq-color-bg-surface)] border border-[var(--fq-color-border-strong)] rounded-lg p-6 flex flex-col justify-between space-y-4">
            <div class="space-y-2">
              <span class="inline-block px-2 py-0.5 text-xs font-semibold rounded bg-[var(--fq-color-primary-subtle)] text-[var(--fq-color-primary)]">
                Schritt 1 · Empfohlen
              </span>
              <h2 class="text-lg font-bold text-[var(--fq-color-text-main)]">
                Erste Organisation gründen
              </h2>
              <p class="text-sm text-[var(--fq-color-text-muted)]">
                Legen Sie Ihren ersten Mandanten als Eigentümer/Bestandshalter, Hausverwaltung oder Dienstleister an.
              </p>
            </div>
            <div>
              <a
                href={~p"/orgs/new"}
                class="inline-flex items-center justify-center rounded-md px-4 font-medium h-11 lg:h-9 text-sm bg-[var(--fq-color-primary)] text-white hover:bg-[var(--fq-color-primary-hover)]"
              >
                Erste Organisation gründen
              </a>
            </div>
          </div>

          <%!-- Card 2 (Secondary): Setup Profile & CLI --%>
          <div class="bg-[var(--fq-color-bg-surface)] border border-[var(--fq-color-border)] rounded-lg p-6 flex flex-col justify-between space-y-4">
            <div class="space-y-2">
              <span class="inline-block px-2 py-0.5 text-xs font-semibold rounded bg-[var(--fq-color-bg-muted)] text-[var(--fq-color-text-muted)]">
                Schritt 2 · Optional
              </span>
              <h2 class="text-lg font-bold text-[var(--fq-color-text-main)]">
                Benutzerprofil &amp; CLI einrichten
              </h2>
              <p class="text-sm text-[var(--fq-color-text-muted)]">
                Passen Sie Ihr automatisch generiertes Handle (<span class="fq-mono">@<%= @current_user.handle %></span>) an oder erstellen Sie ein Personal Access Token für die Go-CLI.
              </p>
            </div>
            <div>
              <a
                href={~p"/settings/profile"}
                class="inline-flex items-center justify-center rounded-md px-4 font-medium h-11 lg:h-9 text-sm bg-[var(--fq-color-bg-surface)] text-[var(--fq-color-text-main)] border border-[var(--fq-color-border-strong)] hover:bg-[var(--fq-color-bg-muted)]"
              >
                Benutzerprofil &amp; CLI einrichten
              </a>
            </div>
          </div>
        </div>
      <% else %>
        <%!-- Organization Overview Table --%>
        <div class="space-y-4">
          <div class="flex items-center justify-between">
            <h2 class="text-lg font-semibold text-[var(--fq-color-text-main)]">Ihre Organisationen</h2>
            <a
              href={~p"/orgs/new"}
              class="inline-flex items-center justify-center rounded-md px-4 font-medium h-11 lg:h-9 text-sm bg-[var(--fq-color-primary)] text-white hover:bg-[var(--fq-color-primary-hover)]"
            >
              + Neue Organisation gründen
            </a>
          </div>

          <.table id="organizations-table" rows={@user_orgs}>
            <:col :let={org} label="Handle">
              <span class="fq-mono font-medium">@<%= org.handle %></span>
            </:col>
            <:col :let={org} label="Anzeigename / Firma">
              <%= org.display_name || org.legal_name || "—" %>
            </:col>
            <:col :let={org} label="Schwerpunkt">
              <%= focus_label(org.primary_focus) %>
            </:col>
            <:col :let={org} label="Meine Rolle">
              <.status_badge status={user_role_in_org(org, @current_user.id)} />
            </:col>
            <:action :let={org}>
              <a
                href={~p"/orgs/#{org.handle}/settings"}
                class="text-xs font-medium text-[var(--fq-color-primary)] hover:underline"
              >
                Einstellungen
              </a>
            </:action>
          </.table>
        </div>
      <% end %>
    </div>
    """
  end

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
