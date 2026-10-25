defmodule FaciqorWeb.FacilityFormLive do
  @moduledoc """
  LiveView-Formular zum Anlegen (`/orgs/:handle/facilities/new`) und Bearbeiten
  (`/orgs/:handle/facilities/:id`) von Objekten inklusive Geo-Suche, Mehrfachtreffer-Auswahl,
  Hausnummern-Bereichsexpansion, deterministischer Titel-Synthese und Geofence-Kartenansicht.
  """
  use FaciqorWeb, :live_view

  alias Faciqor.Accounts
  alias Faciqor.Geo
  alias Faciqor.Geo.Geofence
  alias Faciqor.Operations
  alias Faciqor.Operations.{AddressExpander, NumberRange, TitleBuilder}

  @impl true
  def mount(%{"handle" => handle} = params, _session, socket) do
    user = socket.assigns.current_user
    clean_handle = handle |> to_string() |> String.trim_leading("@")

    case Accounts.get_organization_by_id_or_handle(clean_handle, actor: user) do
      {:ok, org} ->
        org = Ash.load!(org, [:memberships, :logo_blob], actor: user)
        role = find_user_role(org, user.id)
        can_write? = role in [:owner, :member]
        map_config = Geo.map_tile_config(org)

        socket =
          socket
          |> assign(:org, org)
          |> assign(:current_org, org)
          |> assign(:my_role, role)
          |> assign(:can_write?, can_write?)
          |> assign(:map_config, map_config)
          |> assign(:address_query, "")
          |> assign(:parity_filter, "all")
          |> assign(:disambiguations, [])

        mount_mode(socket.assigns.live_action, params, socket)

      {:error, _} ->
        {:ok,
         socket
         |> put_flash(:error, "Organisation nicht gefunden oder kein Zugriff.")
         |> push_navigate(to: ~p"/dashboard")}
    end
  end

  defp mount_mode(:new, _params, socket) do
    if not socket.assigns.can_write? do
      {:ok,
       socket
       |> put_flash(:error, "Gäste (guest) haben nur Lesezugriff und können keine Objekte anlegen.")
       |> push_navigate(to: ~p"/orgs/#{socket.assigns.org.handle}/facilities")}
    else
      user = socket.assigns.current_user
      org = socket.assigns.org
      {:ok, nr} = Operations.get_number_range(:facility, actor: user, tenant: org.id)
      default_geo = Geofence.default_polygon([], 50)

      {:ok,
       socket
       |> assign(:facility, nil)
       |> assign(:business_key_display, NumberRange.preview_next_key(nr))
       |> assign(:addresses, [])
       |> assign(:title_preview, "")
       |> assign(:geofence_radius_meters, 50)
       |> assign(:geofence_polygon, default_geo.polygon)
       |> assign(:custom_polygon?, false)}
    end
  end

  defp mount_mode(:edit, %{"id" => id_or_key}, socket) do
    user = socket.assigns.current_user
    org = socket.assigns.org

    case Operations.get_facility_by_id_or_key(id_or_key, actor: user, tenant: org.id) do
      {:ok, facility} ->
        addresses =
          (facility.addresses || [])
          |> Enum.map(fn a ->
            %{
              id: a.id,
              street: a.street,
              house_number: a.house_number,
              postal_code: a.postal_code,
              city: a.city,
              country_code: a.country_code || "DE",
              latitude: Decimal.to_string(a.latitude, :normal),
              longitude: Decimal.to_string(a.longitude, :normal),
              is_primary: a.is_primary == true,
              provider_place_id: a.provider_place_id
            }
          end)

        {:ok,
         socket
         |> assign(:facility, facility)
         |> assign(:business_key_display, to_string(facility.business_key))
         |> assign(:addresses, addresses)
         |> assign(:title_preview, facility.title)
         |> assign(:geofence_radius_meters, facility.geofence_radius_meters || 50)
         |> assign(:geofence_polygon, facility.geofence_polygon || [])
         |> assign(:custom_polygon?, false)}

      {:error, _} ->
        {:ok,
         socket
         |> put_flash(:error, "Objekt nicht gefunden.")
         |> push_navigate(to: ~p"/orgs/#{org.handle}/facilities")}
    end
  end

  @impl true
  def handle_event("add_address_query", params, socket) do
    if not socket.assigns.can_write? do
      {:noreply, put_flash(socket, :error, "Keine Berechtigung zum Bearbeiten.")}
    else
      query = String.trim(params["query"] || "")
      parity_str = params["parity_filter"] || "all"
      parity = parse_parity(parity_str)
      org = socket.assigns.org

      if query == "" do
        {:noreply, put_flash(socket, :error, "Bitte geben Sie eine Adresse oder einen Hausnummern-Bereich ein.")}
      else
        case AddressExpander.expand_address_query(query, parity) do
          {:ok, expanded_items} ->
            {resolved_new, disambig_items, errors} =
              Enum.reduce(expanded_items, {[], [], []}, fn item, {res_acc, dis_acc, err_acc} ->
                case Geo.search_address(org, item.query) do
                  {:ok, [single]} ->
                    entry = candidate_to_address_entry(single, item)
                    {res_acc ++ [entry], dis_acc, err_acc}

                  {:ok, [_, _ | _] = multiple} ->
                    {res_acc, dis_acc ++ [%{item: item, candidates: multiple}], err_acc}

                  {:ok, []} ->
                    {res_acc, dis_acc, err_acc ++ ["Keine Treffer für '#{item.query}'"]}

                  {:error, :missing_here_api_key} ->
                    {res_acc, dis_acc, err_acc ++ ["HERE Maps API-Schlüssel fehlt in den Organisationseinstellungen."]}

                  {:error, reason} ->
                    {res_acc, dis_acc, err_acc ++ ["Geocoding-Fehler: #{inspect(reason)}"]}
                end
              end)

            updated_addresses = merge_addresses(socket.assigns.addresses, resolved_new)
            socket = update_addresses_and_geofence(socket, updated_addresses)

            socket =
              socket
              |> assign(:address_query, "")
              |> assign(:parity_filter, parity_str)
              |> assign(:disambiguations, socket.assigns.disambiguations ++ disambig_items)

            socket =
              cond do
                errors != [] ->
                  put_flash(socket, :error, Enum.join(errors, " · "))

                disambig_items != [] ->
                  put_flash(
                    socket,
                    :info,
                    "Mehrfachtreffer in der Suche gefunden. Bitte wählen Sie die passende Adresse aus der Liste."
                  )

                true ->
                  socket
              end

            {:noreply, socket}

          {:error, _reason} ->
            {:noreply, put_flash(socket, :error, "Ungültiges Hausnummern- oder Bereichsformat.")}
        end
      end
    end
  end

  def handle_event("select_candidate", %{"dis-idx" => dis_idx_str, "cand-idx" => cand_idx_str}, socket) do
    dis_idx = String.to_integer(dis_idx_str)
    cand_idx = String.to_integer(cand_idx_str)

    case Enum.at(socket.assigns.disambiguations, dis_idx) do
      %{item: item, candidates: candidates} ->
        case Enum.at(candidates, cand_idx) do
          nil ->
            {:noreply, socket}

          chosen ->
            entry = candidate_to_address_entry(chosen, item)
            updated_addresses = merge_addresses(socket.assigns.addresses, [entry])
            remaining_dis = List.delete_at(socket.assigns.disambiguations, dis_idx)

            socket =
              socket
              |> assign(:disambiguations, remaining_dis)
              |> update_addresses_and_geofence(updated_addresses)

            {:noreply, socket}
        end

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("dismiss_disambiguation", %{"dis-idx" => dis_idx_str}, socket) do
    dis_idx = String.to_integer(dis_idx_str)
    remaining = List.delete_at(socket.assigns.disambiguations, dis_idx)
    {:noreply, assign(socket, :disambiguations, remaining)}
  end

  def handle_event("remove_address", %{"index" => idx_str}, socket) do
    if not socket.assigns.can_write? do
      {:noreply, socket}
    else
      idx = String.to_integer(idx_str)
      updated = List.delete_at(socket.assigns.addresses, idx) |> ensure_one_primary()
      {:noreply, update_addresses_and_geofence(socket, updated)}
    end
  end

  def handle_event("set_primary_address", %{"index" => idx_str}, socket) do
    if not socket.assigns.can_write? do
      {:noreply, socket}
    else
      idx = String.to_integer(idx_str)

      updated =
        socket.assigns.addresses
        |> Enum.with_index()
        |> Enum.map(fn {a, i} -> Map.put(a, :is_primary, i == idx) end)

      {:noreply, update_addresses_and_geofence(socket, updated)}
    end
  end

  def handle_event("update_geofence_radius", %{"radius" => radius_str}, socket) do
    radius =
      case Integer.parse(to_string(radius_str)) do
        {r, _} -> min(max(r, 15), 500)
        :error -> 50
      end

    geo = Geofence.default_polygon(socket.assigns.addresses, radius)

    socket =
      socket
      |> assign(:geofence_radius_meters, radius)
      |> assign(:geofence_polygon, geo.polygon)
      |> assign(:custom_polygon?, false)
      |> push_map_state()

    {:noreply, socket}
  end

  def handle_event("update_geofence_polygon", %{"polygon" => vertices}, socket) when is_list(vertices) do
    normalized = Geofence.normalize_polygon_vertices(vertices)

    if length(normalized) >= 3 do
      {:noreply,
       socket
       |> assign(:geofence_polygon, normalized)
       |> assign(:custom_polygon?, true)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("reset_geofence_polygon", _params, socket) do
    geo = Geofence.default_polygon(socket.assigns.addresses, socket.assigns.geofence_radius_meters)

    {:noreply,
     socket
     |> assign(:geofence_polygon, geo.polygon)
     |> assign(:custom_polygon?, false)
     |> push_map_state()}
  end

  def handle_event("save_facility", _params, socket) do
    if not socket.assigns.can_write? do
      {:noreply, put_flash(socket, :error, "Keine Berechtigung zum Speichern.")}
    else
      user = socket.assigns.current_user
      org = socket.assigns.org

      params = %{
        addresses: socket.assigns.addresses,
        geofence_polygon: socket.assigns.geofence_polygon,
        geofence_radius_meters: socket.assigns.geofence_radius_meters
      }

      result =
        case socket.assigns.live_action do
          :new ->
            Operations.create_facility(params, actor: user, tenant: org.id)

          :edit ->
            Operations.update_facility(socket.assigns.facility, params, actor: user, tenant: org.id)
        end

      case result do
        {:ok, saved_facility} ->
          action_word = if socket.assigns.live_action == :new, do: "angelegt", else: "aktualisiert"

          {:noreply,
           socket
           |> put_flash(:info, "Objekt #{saved_facility.business_key} (#{saved_facility.title}) erfolgreich #{action_word}.")
           |> push_navigate(to: ~p"/orgs/#{org.handle}/facilities")}

        {:error, err} ->
          {:noreply, put_flash(socket, :error, format_ash_error(err))}
      end
    end
  end

  # --- Helpers ---

  defp candidate_to_address_entry(candidate, item) do
    street =
      if is_binary(item[:street_hint]) and item[:street_hint] != "" and is_binary(item[:house_number_hint]) do
        item[:street_hint]
      else
        candidate.street
      end

    house_number = item[:house_number_hint] || candidate.house_number

    %{
      street: street,
      house_number: house_number,
      postal_code: candidate.postal_code,
      city: candidate.city,
      country_code: candidate.country_code || "DE",
      latitude: Decimal.to_string(candidate.latitude, :normal),
      longitude: Decimal.to_string(candidate.longitude, :normal),
      is_primary: false,
      provider_place_id: candidate.provider_place_id
    }
  end

  defp merge_addresses(existing, new_entries) do
    combined =
      (existing ++ new_entries)
      |> Enum.uniq_by(fn a ->
        {String.downcase(a.street), String.downcase(a.house_number), String.downcase(a.postal_code)}
      end)

    ensure_one_primary(combined)
  end

  defp ensure_one_primary([]), do: []

  defp ensure_one_primary(list) do
    if Enum.any?(list, & &1.is_primary) do
      list
    else
      List.update_at(list, 0, &Map.put(&1, :is_primary, true))
    end
  end

  defp update_addresses_and_geofence(socket, addresses) do
    title = TitleBuilder.build_title(addresses)

    polygon =
      if socket.assigns.custom_polygon? and addresses != [] do
        socket.assigns.geofence_polygon
      else
        Geofence.default_polygon(addresses, socket.assigns.geofence_radius_meters).polygon
      end

    socket
    |> assign(:addresses, addresses)
    |> assign(:title_preview, title)
    |> assign(:geofence_polygon, polygon)
    |> push_map_state()
  end

  defp push_map_state(socket) do
    push_event(socket, "facility_map:update", %{
      addresses: socket.assigns.addresses,
      polygon: socket.assigns.geofence_polygon
    })
  end

  defp parse_parity("even"), do: :even
  defp parse_parity("odd"), do: :odd
  defp parse_parity(_), do: :all

  defp find_user_role(%{memberships: memberships}, user_id) when is_list(memberships) do
    case Enum.find(memberships, &(&1.user_id == user_id)) do
      %{role: role} -> role
      _ -> :guest
    end
  end

  defp find_user_role(_, _), do: :guest

  defp format_ash_error(%Ash.Error.Invalid{errors: errors}) when is_list(errors) do
    errors
    |> Enum.map_join(" · ", &Exception.message/1)
  end

  defp format_ash_error(err), do: Exception.message(err)

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <%!-- Header --%>
      <div class="flex items-center justify-between flex-wrap gap-4">
        <div>
          <div class="flex items-center gap-2">
            <a
              href={~p"/orgs/#{@org.handle}/facilities"}
              class="text-xs font-medium text-[var(--fq-color-primary)] hover:underline"
            >
              &larr; Zurück zur Objektliste
            </a>
          </div>
          <h1 class="text-2xl font-bold text-[var(--fq-color-text-main)] mt-1">
            <%= if @live_action == :new, do: "Neues Objekt anlegen", else: "Objekt #{@business_key_display}" %>
          </h1>
          <p class="text-sm text-[var(--fq-color-text-muted)]">
            Mandant: <span class="fq-mono font-medium">@<%= @org.handle %></span> ·
            Kartenanbieter: <span class="font-medium"><%= @map_config.provider %></span>
          </p>
        </div>
      </div>

      <%!-- Section 1: BusinessKey & Automatischer Objekt-Titel (Readonly) --%>
      <section class="bg-[var(--fq-color-bg-surface)] border border-[var(--fq-color-border)] rounded-lg p-6 space-y-4">
        <h2 class="text-base font-bold text-[var(--fq-color-text-main)]">
          1. Objekt-Identität &amp; automatisch generierter Titel
        </h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <.input
              id="facility-business-key"
              name="business_key"
              label={if @live_action == :new, do: "BusinessKey (Vorschau aus Nummernkreis)", else: "BusinessKey (Unveränderlich)"}
              monospace={true}
              readonly={true}
              value={@business_key_display}
            />
          </div>
          <div class="md:col-span-2">
            <.input
              id="facility-title-preview"
              name="title"
              label="Objekt-Titel (wird automatisch aus den Teiladressen gebildet)"
              readonly={true}
              placeholder="Wird nach Hinzufügen der Adressen automatisch berechnet..."
              value={@title_preview}
            />
          </div>
        </div>
      </section>

      <%!-- Section 2: Adress-Suche, Bereichsexpansion & Teiladressen --%>
      <section class="bg-[var(--fq-color-bg-surface)] border border-[var(--fq-color-border)] rounded-lg p-6 space-y-4">
        <div>
          <h2 class="text-base font-bold text-[var(--fq-color-text-main)]">
            2. Adressen, Hausnummern-Bereiche &amp; Eckgrundstücke
          </h2>
          <p class="text-xs text-[var(--fq-color-text-muted)]">
            Unterstützt Einzeladressen, Hausnummern-Bereiche (<code class="fq-mono">Hauptstraße 10-13, Berlin</code>),
            Buchstabensuffixe (<code class="fq-mono">Gartenweg 10a-c, Berlin</code>), unterbrochene Listen
            (<code class="fq-mono">Main Street 123, 125, 127</code>) sowie Eckgrundstücke (<code class="fq-mono">Lauterberger Straße 32 / Walkenrieder Straße 4, Berlin</code>).
          </p>
        </div>

        <form
          :if={@can_write?}
          id="facility-address-search-form"
          phx-submit="add_address_query"
          class="grid grid-cols-1 md:grid-cols-12 gap-3 items-end"
        >
          <div class="md:col-span-7">
            <.input
              id="facility-address-query"
              name="query"
              label="Adresse, Bereich oder Eckgrundstück eingeben"
              placeholder="z. B. Hauptstraße 10-13, 10115 Berlin"
              value={@address_query}
            />
          </div>

          <div class="md:col-span-3 space-y-1">
            <label for="facility-parity-filter" class="block text-xs font-medium text-[var(--fq-color-text-main)]">
              Hausnummern-Filter (bei Bereichen)
            </label>
            <select
              id="facility-parity-filter"
              name="parity_filter"
              class="w-full rounded-md border border-[var(--fq-color-border-strong)] bg-[var(--fq-color-bg-surface)] px-3 text-sm text-[var(--fq-color-text-main)] h-11 lg:h-9 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#2563EB]"
            >
              <option value="all" selected={@parity_filter == "all"}>Alle Hausnummern</option>
              <option value="even" selected={@parity_filter == "even"}>Nur gerade (z. B. 10, 12, 14)</option>
              <option value="odd" selected={@parity_filter == "odd"}>Nur ungerade (z. B. 11, 13, 15)</option>
            </select>
          </div>

          <div class="md:col-span-2">
            <.button type="submit" class="w-full">
              Adresse hinzufügen
            </.button>
          </div>
        </form>

        <%!-- Mehrfachtreffer-Hinweis & Auswahl --%>
        <div
          :if={@disambiguations != []}
          id="disambiguation-panel"
          class="bg-[#FFFBEB] border border-[#F59E0B] rounded-lg p-4 space-y-3"
        >
          <div class="flex items-center justify-between">
            <span class="text-xs font-bold text-[#92400E]">
              Mehrfachtreffer in der Geo-Suche gefunden – Bitte wählen Sie das gewünschte Ergebnis:
            </span>
          </div>

          <div :for={{dis, dis_idx} <- Enum.with_index(@disambiguations)} class="bg-white border border-[#FCD34D] rounded p-3 space-y-2">
            <div class="flex items-center justify-between">
              <span class="text-xs font-semibold text-[var(--fq-color-text-main)]">
                Suchanfrage: <code class="fq-mono"><%= dis.item.query %></code>
              </span>
              <button
                type="button"
                phx-click="dismiss_disambiguation"
                phx-value-dis-idx={dis_idx}
                class="text-xs text-[var(--fq-color-text-muted)] hover:underline"
              >
                Verwerfen
              </button>
            </div>

            <div class="divide-y divide-[var(--fq-color-border)]">
              <div
                :for={{cand, cand_idx} <- Enum.with_index(dis.candidates)}
                class="py-2 flex items-center justify-between gap-4"
              >
                <div>
                  <div class="text-xs font-medium text-[var(--fq-color-text-main)]">
                    <%= cand.formatted_label %>
                  </div>
                  <div class="text-[11px] fq-mono tabular-nums text-[var(--fq-color-text-muted)]">
                    Lat: <%= Decimal.to_string(cand.latitude, :normal) %> · Lon: <%= Decimal.to_string(cand.longitude, :normal) %>
                  </div>
                </div>
                <button
                  type="button"
                  id={"select-candidate-#{dis_idx}-#{cand_idx}"}
                  phx-click="select_candidate"
                  phx-value-dis-idx={dis_idx}
                  phx-value-cand-idx={cand_idx}
                  class="cursor-pointer px-3 py-1 rounded text-xs font-semibold bg-[var(--fq-color-primary)] text-white hover:bg-[var(--fq-color-primary-hover)]"
                >
                  Auswählen
                </button>
              </div>
            </div>
          </div>
        </div>

        <%!-- Liste der erfassten Teiladressen --%>
        <%= if @addresses == [] do %>
          <div id="no-addresses-hint" class="p-4 rounded border border-dashed border-[var(--fq-color-border-strong)] text-center text-xs text-[var(--fq-color-text-muted)]">
            Noch keine Adresse hinzugefügt. Geben Sie oben eine Adresse oder einen Bereich ein.
          </div>
        <% else %>
          <.table id="facility-addresses-table" rows={Enum.with_index(@addresses)}>
            <:col :let={{addr, _idx}} label="Straße">
              <span class="font-medium"><%= addr.street %></span>
            </:col>
            <:col :let={{addr, _idx}} label="Hausnr.">
              <span class="fq-mono tabular-nums font-semibold"><%= addr.house_number %></span>
            </:col>
            <:col :let={{addr, _idx}} label="PLZ & Ort">
              <%= addr.postal_code %> <%= addr.city %> (<%= addr.country_code %>)
            </:col>
            <:col :let={{addr, _idx}} label="Breitengrad (Lat)">
              <span class="fq-mono tabular-nums text-xs"><%= addr.latitude %></span>
            </:col>
            <:col :let={{addr, _idx}} label="Längengrad (Lon)">
              <span class="fq-mono tabular-nums text-xs"><%= addr.longitude %></span>
            </:col>
            <:col :let={{addr, idx}} label="Rolle">
              <%= if addr.is_primary do %>
                <span class="inline-flex items-center px-2 py-0.5 rounded text-[11px] font-semibold bg-[var(--fq-color-primary-subtle)] text-[var(--fq-color-primary)]">
                  Hauptadresse
                </span>
              <% else %>
                <button
                  :if={@can_write?}
                  type="button"
                  phx-click="set_primary_address"
                  phx-value-index={idx}
                  class="cursor-pointer text-xs text-[var(--fq-color-text-muted)] hover:text-[var(--fq-color-primary)] hover:underline"
                >
                  Als Hauptadresse setzen
                </button>
              <% end %>
            </:col>
            <:action :let={{_addr, idx}}>
              <button
                :if={@can_write?}
                type="button"
                id={"remove-address-#{idx}"}
                phx-click="remove_address"
                phx-value-index={idx}
                class="cursor-pointer text-xs font-medium text-red-600 hover:underline"
              >
                Entfernen
              </button>
            </:action>
          </.table>
        <% end %>
      </section>

      <%!-- Section 3: Kartenansicht & Geofence-Zone --%>
      <section class="bg-[var(--fq-color-bg-surface)] border border-[var(--fq-color-border)] rounded-lg p-6 space-y-4">
        <div class="flex items-center justify-between flex-wrap gap-4">
          <div>
            <h2 class="text-base font-bold text-[var(--fq-color-text-main)]">
              3. Kartenansicht &amp; Geofence-Zone (PostGIS Polygon)
            </h2>
            <p class="text-xs text-[var(--fq-color-text-muted)]">
              Zeigt alle erfassten Teiladressen und die umschließende Geofence-Zone zur Positionsprüfung.
              Sie können den Puffer-Radius anpassen oder die Polygon-Eckpunkte direkt auf der Karte verschieben.
            </p>
          </div>

          <form
            :if={@can_write?}
            id="geofence-radius-form"
            phx-change="update_geofence_radius"
            class="flex items-center gap-3"
          >
            <label for="geofence-radius-slider" class="text-xs font-medium text-[var(--fq-color-text-main)]">
              Geofence-Radius:
              <span class="fq-mono tabular-nums font-bold text-[var(--fq-color-primary)]">
                <%= @geofence_radius_meters %>m
              </span>
            </label>
            <input
              id="geofence-radius-slider"
              type="range"
              name="radius"
              min="15"
              max="500"
              step="5"
              value={@geofence_radius_meters}
              class="w-36 accent-[var(--fq-color-primary)]"
            />
            <button
              :if={@custom_polygon?}
              type="button"
              phx-click="reset_geofence_polygon"
              class="cursor-pointer text-xs font-medium text-[var(--fq-color-primary)] hover:underline"
            >
              Auf Standard-Polygon zurücksetzen
            </button>
          </form>
        </div>

        <%!-- DOM-isolierter Karten-Container gemäß AGENTS.md § 4.4 --%>
        <div
          id="facility-map-wrapper"
          phx-update="ignore"
          phx-hook="FacilityMap"
          data-tile-url={@map_config.tile_url}
          data-attribution={@map_config.attribution}
          data-provider={@map_config.provider}
          data-editable={to_string(@can_write?)}
          data-addresses={Jason.encode!(@addresses)}
          data-polygon={Jason.encode!(@geofence_polygon)}
          class="w-full h-96 rounded-lg border border-[var(--fq-color-border-strong)] bg-[var(--fq-color-bg-muted)] relative overflow-hidden"
        >
          <div id="facility-map-canvas" class="w-full h-full"></div>
        </div>
      </section>

      <%!-- Footer Actions --%>
      <div class="flex items-center justify-end gap-3">
        <a
          href={~p"/orgs/#{@org.handle}/facilities"}
          class="inline-flex items-center justify-center rounded-md px-4 font-medium h-11 lg:h-9 text-sm bg-[var(--fq-color-bg-surface)] text-[var(--fq-color-text-main)] border border-[var(--fq-color-border-strong)] hover:bg-[var(--fq-color-bg-muted)]"
        >
          Abbrechen
        </a>

        <.button
          :if={@can_write?}
          id="save-facility-btn"
          type="button"
          phx-click="save_facility"
        >
          <%= if @live_action == :new, do: "Objekt verbindlich anlegen", else: "Änderungen speichern" %>
        </.button>
      </div>
    </div>
    """
  end
end
