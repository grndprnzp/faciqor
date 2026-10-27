defmodule FaciqorWeb.FacilityIndexLive do
  @moduledoc """
  LiveView zur Übersicht, Suche und Verwaltung aller Objekte (`Facilities`)
  einer Organisation unter `/orgs/:handle/facilities`.
  """
  use FaciqorWeb, :live_view

  alias Faciqor.Accounts
  alias Faciqor.Operations

  @impl true
  def mount(%{"handle" => handle}, _session, socket) do
    user = socket.assigns.current_user
    clean_handle = handle |> to_string() |> String.trim_leading("@")

    case Accounts.get_organization_by_id_or_handle(clean_handle, actor: user) do
      {:ok, org} ->
        org = Ash.load!(org, [:memberships, :logo_blob], actor: user)
        role = find_user_role(org, user.id)
        can_write? = role in [:owner, :member]
        is_owner? = role == :owner

        if connected?(socket) do
          Phoenix.PubSub.subscribe(Faciqor.PubSub, "tenant:#{org.id}:operations")
        end

        {:ok, facilities} =
          Operations.list_facilities(
            actor: user,
            tenant: org.id,
            include_archived?: false
          )

        {:ok,
         socket
         |> assign(:org, org)
         |> assign(:current_org, org)
         |> assign(:my_role, role)
         |> assign(:can_write?, can_write?)
         |> assign(:is_owner?, is_owner?)
         |> assign(:include_archived?, false)
         |> assign(:search, "")
         |> assign(:facilities, facilities)}

      {:error, _} ->
        {:ok,
         socket
         |> put_flash(:error, "Organisation nicht gefunden oder kein Zugriff.")
         |> push_navigate(to: ~p"/dashboard")}
    end
  end

  @impl true
  def handle_event("filter_facilities", params, socket) do
    search = params["search"] || socket.assigns.search
    include_archived? = params["include_archived"] == "true"

    socket =
      socket
      |> assign(:search, search)
      |> assign(:include_archived?, include_archived?)
      |> reload_facilities()

    {:noreply, socket}
  end

  def handle_event("archive_facility", %{"id" => id}, socket) do
    user = socket.assigns.current_user
    org = socket.assigns.org

    with {:ok, facility} <- Operations.get_facility_by_id_or_key(id, actor: user, tenant: org.id),
         {:ok, _archived} <- Operations.archive_facility(facility, actor: user, tenant: org.id) do
      {:noreply,
       socket
       |> reload_facilities()
       |> put_flash(:info, "Objekt #{facility.business_key} wurde archiviert.")}
    else
      _ ->
        {:noreply, put_flash(socket, :error, "Archivierung fehlgeschlagen.")}
    end
  end

  def handle_event("unarchive_facility", %{"id" => id}, socket) do
    user = socket.assigns.current_user
    org = socket.assigns.org

    with {:ok, facility} <- Operations.get_facility_by_id_or_key(id, actor: user, tenant: org.id),
         {:ok, _unarchived} <- Operations.unarchive_facility(facility, actor: user, tenant: org.id) do
      {:noreply,
       socket
       |> reload_facilities()
       |> put_flash(:info, "Objekt #{facility.business_key} wurde reaktiviert.")}
    else
      _ ->
        {:noreply, put_flash(socket, :error, "Reaktivierung fehlgeschlagen.")}
    end
  end

  def handle_event("delete_facility", %{"id" => id}, socket) do
    user = socket.assigns.current_user
    org = socket.assigns.org

    with {:ok, facility} <- Operations.get_facility_by_id_or_key(id, actor: user, tenant: org.id),
         {:ok, :ok} <- Operations.delete_facility(facility, actor: user, tenant: org.id) do
      {:noreply,
       socket
       |> reload_facilities()
       |> put_flash(:info, "Objekt #{facility.business_key} wurde vollständig gelöscht.")}
    else
      _ ->
        {:noreply, put_flash(socket, :error, "Löschen nicht erlaubt oder fehlgeschlagen.")}
    end
  end

  @impl true
  def handle_info({event, _facility_id}, socket)
      when event in [:facility_created, :facility_updated, :facility_archived, :facility_unarchived, :facility_deleted] do
    {:noreply, reload_facilities(socket)}
  end

  def handle_info(_msg, socket), do: {:noreply, socket}

  defp reload_facilities(socket) do
    user = socket.assigns.current_user
    org = socket.assigns.org

    {:ok, facilities} =
      Operations.list_facilities(
        actor: user,
        tenant: org.id,
        include_archived?: socket.assigns.include_archived?,
        search: socket.assigns.search
      )

    assign(socket, :facilities, facilities)
  end

  defp find_user_role(%{memberships: memberships}, user_id) when is_list(memberships) do
    case Enum.find(memberships, &(&1.user_id == user_id)) do
      %{role: role} -> role
      _ -> :guest
    end
  end

  defp find_user_role(_, _), do: :guest

  @impl true
  def render(assigns) do
    active_count = Enum.count(assigns.facilities, &is_nil(&1.archived_at))
    archived_count = Enum.count(assigns.facilities, &(not is_nil(&1.archived_at)))
    assigns = assign(assigns, active_count: active_count, archived_count: archived_count)

    ~H"""
    <div class="space-y-5">
      <%!-- GitHub-Style Context Subhead --%>
      <.gh_subhead>
        <:title>
          <span>Objekte &amp; Liegenschaften</span>
          <span class="fq-mono text-sm font-normal text-[var(--fq-color-text-muted)]">
            (@<%= @org.handle %>)
          </span>
          <.status_badge status={@my_role} />
        </:title>
        <:description>
          Verwaltung aller Grundstücke, Mehrfach-Hausnummern, Eckgrundstücke und Geofence-Zonen
        </:description>
        <:actions>
          <a
            href={~p"/orgs/#{@org.handle}/settings"}
            class="inline-flex items-center justify-center rounded-md px-3 font-medium h-11 lg:h-9 text-xs bg-[var(--fq-color-bg-surface)] text-[var(--fq-color-text-main)] border border-[var(--fq-color-border-strong)] hover:bg-[var(--fq-color-bg-muted)] transition-colors"
          >
            Nummernkreise &amp; Geo-Provider
          </a>

          <a
            :if={@can_write?}
            id="new-facility-btn"
            href={~p"/orgs/#{@org.handle}/facilities/new"}
            class="inline-flex items-center justify-center rounded-md px-4 font-medium h-11 lg:h-9 text-sm bg-[var(--fq-color-primary)] text-white hover:bg-[var(--fq-color-primary-hover)] transition-colors"
          >
            + Neues Objekt anlegen
          </a>
        </:actions>
      </.gh_subhead>

      <%!-- GitHub-Style Filter & Search Toolbar --%>
      <form
        id="facilities-filter-form"
        phx-change="filter_facilities"
        phx-submit="filter_facilities"
        class="bg-[var(--fq-color-bg-surface)] border border-[var(--fq-color-border)] rounded-lg p-3 flex items-center justify-between flex-wrap gap-3"
      >
        <div class="w-full sm:w-96 flex-1 max-w-lg">
          <.input
            id="facilities-search-input"
            name="search"
            placeholder="Suche nach BusinessKey, Titel oder Straße..."
            value={@search}
          />
        </div>

        <div class="flex items-center gap-4">
          <div class="flex items-center gap-2 px-3 py-1.5 rounded-md bg-[var(--fq-color-bg-muted)] border border-[var(--fq-color-border)]">
            <input
              id="facilities-include-archived"
              type="checkbox"
              name="include_archived"
              value="true"
              checked={@include_archived?}
              class="h-4 w-4 rounded border-[var(--fq-color-border-strong)] text-[var(--fq-color-primary)] cursor-pointer"
            />
            <label for="facilities-include-archived" class="text-xs font-medium text-[var(--fq-color-text-main)] cursor-pointer">
              Archivierte Objekte einblenden
            </label>
          </div>
        </div>
      </form>

      <%= if @facilities == [] do %>
        <.gh_box id="facilities-empty-state" body_class="p-10 text-center space-y-3">
          <h2 class="text-base font-bold text-[var(--fq-color-text-main)]">
            Noch keine Objekte erfasst
          </h2>
          <p class="text-xs text-[var(--fq-color-text-muted)] max-w-md mx-auto">
            Legen Sie Ihr erstes Objekt inklusive Adressvervollständigung, Teiladressen und Geofence-Zone an.
          </p>
          <div :if={@can_write?} class="pt-2">
            <a
              href={~p"/orgs/#{@org.handle}/facilities/new"}
              class="inline-flex items-center justify-center rounded-md px-4 font-medium h-11 lg:h-9 text-sm bg-[var(--fq-color-primary)] text-white hover:bg-[var(--fq-color-primary-hover)]"
            >
              Erstes Objekt anlegen
            </a>
          </div>
        </.gh_box>
      <% else %>
        <.table id="facilities-table" rows={@facilities}>
          <:header_bar>
            <div class="flex items-center gap-4">
              <span class="inline-flex items-center gap-1.5 font-semibold text-[var(--fq-color-text-main)]">
                <span class="w-2 h-2 rounded-full bg-emerald-500"></span>
                <span class="fq-mono tabular-nums"><%= @active_count %></span>
                <span>Aktiv</span>
              </span>
              <span
                :if={@include_archived? or @archived_count > 0}
                class="inline-flex items-center gap-1.5 text-[var(--fq-color-text-muted)]"
              >
                <span class="w-2 h-2 rounded-full bg-slate-400"></span>
                <span class="fq-mono tabular-nums"><%= @archived_count %></span>
                <span>Archiviert</span>
              </span>
            </div>
            <div class="text-[var(--fq-color-text-muted)] fq-mono text-[11px]">
              Gesamt: <%= length(@facilities) %> Objekt(e)
            </div>
          </:header_bar>
          <:col :let={facility} label="BusinessKey">
            <span class="fq-mono tabular-nums font-bold text-xs text-[var(--fq-color-primary)]">
              <%= facility.business_key %>
            </span>
          </:col>
          <:col :let={facility} label="Titel">
            <a
              href={~p"/orgs/#{@org.handle}/facilities/#{facility.id}"}
              class="font-semibold text-[var(--fq-color-text-main)] hover:text-[var(--fq-color-primary)] hover:underline"
            >
              <%= facility.title %>
            </a>
          </:col>
          <:col :let={facility} label="Teiladressen">
            <span class="fq-mono tabular-nums text-xs text-[var(--fq-color-text-muted)]">
              <%= length(facility.addresses || []) %> Adresse(n)
            </span>
          </:col>
          <:col :let={facility} label="Geofence">
            <span class="fq-mono tabular-nums text-xs text-[var(--fq-color-text-muted)]">
              <%= length(facility.geofence_polygon || []) %> Eckpunkte (<%= facility.geofence_radius_meters %>m)
            </span>
          </:col>
          <:col :let={facility} label="Status">
            <%= if facility.archived_at do %>
              <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-[var(--fq-color-bg-muted)] text-[var(--fq-color-text-muted)] border border-[var(--fq-color-border)]">
                Archiviert
              </span>
            <% else %>
              <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-[#ECFDF5] text-[#065F46]">
                Aktiv
              </span>
            <% end %>
          </:col>
          <:action :let={facility}>
            <div class="flex items-center justify-end gap-3">
              <a
                href={~p"/orgs/#{@org.handle}/facilities/#{facility.id}"}
                class="text-xs font-medium text-[var(--fq-color-primary)] hover:underline"
              >
                <%= if @can_write?, do: "Bearbeiten", else: "Details" %>
              </a>

              <%= if @can_write? do %>
                <%= if facility.archived_at do %>
                  <button
                    type="button"
                    phx-click="unarchive_facility"
                    phx-value-id={facility.id}
                    class="cursor-pointer text-xs font-medium text-emerald-700 hover:underline"
                  >
                    Reaktivieren
                  </button>
                <% else %>
                  <button
                    type="button"
                    phx-click="archive_facility"
                    phx-value-id={facility.id}
                    class="cursor-pointer text-xs font-medium text-amber-700 hover:underline"
                  >
                    Archivieren
                  </button>
                <% end %>
              <% end %>

              <button
                :if={@is_owner?}
                type="button"
                phx-click="delete_facility"
                phx-value-id={facility.id}
                class="cursor-pointer text-xs font-medium text-red-600 hover:underline"
              >
                Löschen
              </button>
            </div>
          </:action>
        </.table>
      <% end %>
    </div>
    """
  end
end
