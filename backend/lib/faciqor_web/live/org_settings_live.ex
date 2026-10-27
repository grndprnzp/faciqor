defmodule FaciqorWeb.OrgSettingsLive do
  use FaciqorWeb, :live_view

  alias Faciqor.Accounts
  alias Faciqor.Media
  alias Faciqor.Media.ImageProcessing
  alias Faciqor.Media.Storage
  alias Faciqor.Media.Workers.ProcessImageVariants
  alias Faciqor.Operations
  alias Faciqor.Operations.NumberRange

  @impl true
  def mount(%{"handle" => handle}, _session, socket) do
    user = socket.assigns.current_user
    clean_handle = handle |> to_string() |> String.trim_leading("@")

    case Accounts.get_organization_by_id_or_handle(clean_handle, actor: user) do
      {:ok, org} ->
        org = Ash.load!(org, [:memberships, :logo_blob], actor: user)
        role = find_user_role(org, user.id)
        is_owner? = role == :owner
        logo_url = resolve_logo_url(org)
        {:ok, number_range} = Operations.get_number_range(:facility, actor: user, tenant: org.id)

        {:ok,
         socket
         |> assign(:org, org)
         |> assign(:current_org, org)
         |> assign(:my_role, role)
         |> assign(:is_owner?, is_owner?)
         |> assign(:active_tab, :general)
         |> assign(:logo_url, logo_url)
         |> assign(:number_range, number_range)
         |> assign(:nr_preview, NumberRange.preview_next_key(number_range))
         |> assign(:map_provider, to_string(org.map_provider || :openstreetmap))
         |> assign(:geocoding_provider, to_string(org.geocoding_provider || :nominatim))
         |> assign(:here_api_key, org.here_api_key || "")
         |> assign(:apply_to_all_owned_orgs, false)}

      {:error, _} ->
        {:ok,
         socket
         |> put_flash(:error, "Organisation nicht gefunden oder kein Zugriff.")
         |> push_navigate(to: ~p"/dashboard")}
    end
  end

  @impl true
  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    active_tab =
      case tab do
        "general" -> :general
        "billing" -> :billing
        "number_ranges" -> :number_ranges
        "geo" -> :geo
        "danger" -> :danger
        _ -> :general
      end

    {:noreply, assign(socket, :active_tab, active_tab)}
  end

  def handle_event("save_org", params, socket) do
    user = socket.assigns.current_user
    org = socket.assigns.org

    attrs = %{
      handle: params["handle"] || to_string(org.handle),
      primary_focus: parse_focus(params["primary_focus"], org.primary_focus),
      display_name: params["display_name"],
      legal_name: params["legal_name"],
      legal_form: params["legal_form"],
      street_address: params["street_address"],
      postal_code: params["postal_code"],
      city: params["city"],
      country_code: params["country_code"] || "DE",
      tax_id: params["tax_id"],
      vat_id: params["vat_id"],
      contact_email: params["contact_email"]
    }

    case org
         |> Ash.Changeset.for_update(:update_organization, attrs)
         |> Ash.update(actor: user) do
      {:ok, updated_org} ->
        updated_org = Ash.load!(updated_org, :memberships, actor: user)

        {:noreply,
         socket
         |> assign(:org, updated_org)
         |> put_flash(:info, "Organisations-Stammdaten wurden gespeichert.")}

      {:error, _err} ->
        {:noreply, put_flash(socket, :error, "Änderungen konnten nicht gespeichert werden.")}
    end
  end

  def handle_event("preview_number_range", params, socket) do
    nr = socket.assigns.number_range

    preview_attrs = %{
      prefix: params["prefix"] || "",
      start_value: parse_int(params["start_value"], nr.start_value),
      current_value: parse_optional_int(params["current_value"], nr.current_value),
      step: parse_int(params["step"], nr.step),
      suffix: params["suffix"] || ""
    }

    {:noreply, assign(socket, :nr_preview, NumberRange.preview_next_key(preview_attrs, Date.utc_today()))}
  end

  def handle_event("save_number_range", params, socket) do
    user = socket.assigns.current_user
    org = socket.assigns.org
    nr = socket.assigns.number_range

    attrs = %{
      entity_type: :facility,
      prefix: params["prefix"] || "",
      start_value: parse_int(params["start_value"], nr.start_value),
      current_value: parse_optional_int(params["current_value"], nil),
      step: parse_int(params["step"], nr.step),
      suffix: params["suffix"] || ""
    }

    case Operations.update_number_range(attrs, actor: user, tenant: org.id) do
      {:ok, updated_nr} ->
        {:noreply,
         socket
         |> assign(:number_range, updated_nr)
         |> assign(:nr_preview, NumberRange.preview_next_key(updated_nr))
         |> put_flash(:info, "Nummernkreis erfolgreich gespeichert.")}

      {:error, _err} ->
        {:noreply, put_flash(socket, :error, "Nummernkreis konnte nicht gespeichert werden.")}
    end
  end

  def handle_event("change_geo_provider", params, socket) do
    map_p = params["map_provider"] || socket.assigns.map_provider
    geo_p = params["geocoding_provider"] || socket.assigns.geocoding_provider
    api_key = Map.get(params, "here_api_key", socket.assigns.here_api_key)
    apply_all? = params["apply_to_all_owned_orgs"] == "true"

    {:noreply,
     socket
     |> assign(:map_provider, map_p)
     |> assign(:geocoding_provider, geo_p)
     |> assign(:here_api_key, api_key)
     |> assign(:apply_to_all_owned_orgs, apply_all?)}
  end

  def handle_event("save_geo_provider", params, socket) do
    user = socket.assigns.current_user
    org = socket.assigns.org

    map_provider = parse_map_provider(params["map_provider"])
    geocoding_provider = parse_geocoding_provider(params["geocoding_provider"])
    here_api_key = String.trim(params["here_api_key"] || "")
    apply_all? = params["apply_to_all_owned_orgs"] == "true"

    attrs = %{
      map_provider: map_provider,
      geocoding_provider: geocoding_provider,
      here_api_key: if(here_api_key == "", do: nil, else: here_api_key)
    }

    case Accounts.update_geo_provider_config(
           org,
           attrs,
           actor: user,
           apply_to_all_owned_orgs: apply_all?
         ) do
      {:ok, updated_org, updated_handles} ->
        updated_org = Ash.load!(updated_org, [:memberships, :logo_blob], actor: user)

        msg =
          if apply_all? and length(updated_handles) > 1 do
            "Karten- & Geo-Provider für #{length(updated_handles)} Organisationen gespeichert (#{Enum.map_join(updated_handles, ", ", &("@" <> &1))})."
          else
            "Karten- & Geo-Provider-Einstellungen wurden gespeichert."
          end

        {:noreply,
         socket
         |> assign(:org, updated_org)
         |> assign(:current_org, updated_org)
         |> assign(:map_provider, to_string(updated_org.map_provider))
         |> assign(:geocoding_provider, to_string(updated_org.geocoding_provider))
         |> assign(:here_api_key, updated_org.here_api_key || "")
         |> assign(:apply_to_all_owned_orgs, false)
         |> put_flash(:info, msg)}

      {:error, _err} ->
        {:noreply,
         put_flash(
           socket,
           :error,
           "Provider-Einstellungen konnten nicht gespeichert werden. Bei Auswahl von HERE Maps ist ein API-Schlüssel erforderlich."
         )}
    end
  end

  def handle_event("soft_delete_org", _params, socket) do
    user = socket.assigns.current_user
    org = socket.assigns.org

    case org
         |> Ash.Changeset.for_update(:soft_delete, %{reason: :manual_by_owner})
         |> Ash.update(actor: user) do
      {:ok, _deleted_org} ->
        {:noreply,
         socket
         |> put_flash(:info, "Organisation @#{org.handle} wurde zur Löschung vorgemerkt (60 Tage Frist).")
         |> push_navigate(to: ~p"/dashboard")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Löschung nicht möglich.")}
    end
  end

  def handle_event("save_logo", %{"data" => "data:image/" <> _ = data_url}, socket) do
    if not socket.assigns.is_owner? do
      {:noreply, put_flash(socket, :error, "Nur Eigentümer (Owner) können das Firmenlogo ändern.")}
    else
      user = socket.assigns.current_user
      org = socket.assigns.org
      [_header, base64_content] = String.split(data_url, ",", parts: 2)

      case Base.decode64(base64_content) do
        {:ok, binary} ->
          case ImageProcessing.validate_avatar_or_logo(binary) do
            {:ok, %{width: width, height: height}} ->
              bucket = Storage.public_bucket()
              key = "logos/#{org.id}/#{Ecto.UUID.generate()}.png"

              case Storage.put_object(bucket, key, binary, "image/png") do
                {:ok, _} ->
                  {:ok, blob} =
                    Media.create_storage_blob(
                      %{
                        bucket: bucket,
                        key: key,
                        content_type: "image/png",
                        byte_size: byte_size(binary),
                        width: width,
                        height: height,
                        context: :organization_logo,
                        organization_id: org.id
                      },
                      actor: user
                    )

                  case Accounts.set_organization_logo(org, blob.id, actor: user) do
                    {:ok, updated_org} ->
                      ProcessImageVariants.new(%{"blob_id" => blob.id})
                      |> Oban.insert()

                      updated_org = Ash.load!(updated_org, [:memberships, :logo_blob], actor: user)

                      {:noreply,
                       socket
                       |> assign(:org, updated_org)
                       |> assign(:current_org, updated_org)
                       |> assign(:logo_url, resolve_logo_url(updated_org))
                       |> put_flash(:info, "Firmenlogo erfolgreich aktualisiert.")}

                    {:error, _} ->
                      {:noreply, put_flash(socket, :error, "Fehler beim Zuweisen des Logos.")}
                  end

                {:error, _} ->
                  {:noreply, put_flash(socket, :error, "Fehler beim Speichern der Bilddatei.")}
              end

            {:error, {:not_square, w, h}} ->
              {:noreply, put_flash(socket, :error, "Das Logo muss quadratisch sein (1:1 Seitenverhältnis, aktuell #{w}x#{h}).")}

            {:error, {:dimensions_too_small, w, h, min}} ->
              {:noreply, put_flash(socket, :error, "Das Logo muss mindestens #{min}x#{min}px groß sein (aktuell #{w}x#{h}px).")}

            {:error, :file_too_large} ->
              {:noreply, put_flash(socket, :error, "Das Logo darf maximal 5MB groß sein.")}

            {:error, _} ->
              {:noreply, put_flash(socket, :error, "Ungültiges Bildformat.")}
          end

        :error ->
          {:noreply, put_flash(socket, :error, "Fehler beim Dekodieren der Bilddaten.")}
      end
    end
  end

  def handle_event("save_logo", _params, socket) do
    {:noreply, put_flash(socket, :error, "Ungültige Bildübertragung.")}
  end

  def handle_event("remove_logo", _params, socket) do
    if not socket.assigns.is_owner? do
      {:noreply, put_flash(socket, :error, "Nur Eigentümer (Owner) können das Firmenlogo entfernen.")}
    else
      user = socket.assigns.current_user
      org = socket.assigns.org

      case Accounts.remove_organization_logo(org, actor: user) do
        {:ok, updated_org} ->
          updated_org = Ash.load!(updated_org, [:memberships, :logo_blob], actor: user)

          {:noreply,
           socket
           |> assign(:org, updated_org)
           |> assign(:current_org, updated_org)
           |> assign(:logo_url, nil)
           |> put_flash(:info, "Firmenlogo wurde entfernt.")}

        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Logo konnte nicht entfernt werden.")}
      end
    end
  end

  defp find_user_role(%{memberships: memberships}, user_id) when is_list(memberships) do
    case Enum.find(memberships, &(&1.user_id == user_id)) do
      %{role: role} -> role
      _ -> :guest
    end
  end

  defp find_user_role(_, _), do: :guest

  defp parse_focus("property_owner", _), do: :property_owner
  defp parse_focus("property_manager", _), do: :property_manager
  defp parse_focus("service_provider", _), do: :service_provider
  defp parse_focus(_, fallback), do: fallback

  defp parse_map_provider("here"), do: :here
  defp parse_map_provider(_), do: :openstreetmap

  defp parse_geocoding_provider("here"), do: :here
  defp parse_geocoding_provider(_), do: :nominatim

  defp parse_int(val, fallback) when is_binary(val) do
    case Integer.parse(String.trim(val)) do
      {n, ""} when n > 0 -> n
      _ -> fallback
    end
  end

  defp parse_int(val, _fallback) when is_integer(val) and val > 0, do: val
  defp parse_int(_, fallback), do: fallback

  defp parse_optional_int(nil, fallback), do: fallback
  defp parse_optional_int("", _fallback), do: nil

  defp parse_optional_int(val, fallback) when is_binary(val) do
    case Integer.parse(String.trim(val)) do
      {n, ""} when n >= 0 -> n
      _ -> fallback
    end
  end

  defp parse_optional_int(val, _fallback) when is_integer(val) and val >= 0, do: val
  defp parse_optional_int(_, fallback), do: fallback

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <%!-- GitHub-Style Context Header Bar --%>
      <div class="pb-4 border-b border-[var(--fq-color-border)] flex items-center justify-between flex-wrap gap-4">
        <div class="flex items-center gap-3.5">
          <div class="w-12 h-12 rounded-lg overflow-hidden border border-[var(--fq-color-border-strong)] bg-[var(--fq-color-bg-muted)] flex items-center justify-center shrink-0">
            <%= if @logo_url do %>
              <img src={@logo_url} alt="Firmenlogo" class="w-full h-full object-cover" />
            <% else %>
              <span class="text-base font-bold text-[var(--fq-color-text-main)] fq-mono">
                <%= String.upcase(String.slice(@org.display_name || to_string(@org.handle) || "O", 0, 2)) %>
              </span>
            <% end %>
          </div>
          <div>
            <div class="flex items-center gap-2">
              <h1 class="text-xl font-bold text-[var(--fq-color-text-main)] fq-mono">
                @<%= @org.handle %>
              </h1>
              <.status_badge status={@my_role} />
            </div>
            <p class="text-xs text-[var(--fq-color-text-muted)]">
              Organisations-Stammdaten &amp; Mandanten-Konfiguration
            </p>
          </div>
        </div>

        <div class="flex items-center gap-3">
          <a
            href={~p"/orgs/#{@org.handle}/facilities"}
            class="inline-flex items-center justify-center rounded-md px-3.5 font-medium h-11 lg:h-9 text-xs bg-[var(--fq-color-bg-surface)] text-[var(--fq-color-text-main)] border border-[var(--fq-color-border-strong)] hover:bg-[var(--fq-color-bg-muted)] transition-colors"
          >
            Objekte &amp; Liegenschaften verwalten
          </a>
        </div>
      </div>

      <%!-- GitHub 2-Column Settings Body (Left Vertical Sidebar + Right Active Category Panel) --%>
      <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
        <%!-- Left Vertical Navigation Sidebar --%>
        <aside id="org-settings-sidebar" class="lg:col-span-3 space-y-4">
          <nav class="space-y-1" aria-label="Organisations-Einstellungen">
            <div class="px-3 py-1.5 text-[11px] font-semibold uppercase tracking-wider text-[var(--fq-color-text-muted)]">
              Allgemein
            </div>
            <button
              type="button"
              id="org-tab-general"
              phx-click="switch_tab"
              phx-value-tab="general"
              class={[
                "w-full text-left px-3 py-2 rounded-md text-xs font-medium flex items-center justify-between transition-colors cursor-pointer",
                if(@active_tab == :general,
                  do: "bg-[var(--fq-color-bg-muted)] text-[var(--fq-color-text-main)] font-semibold border-l-2 border-[var(--fq-color-primary)]",
                  else: "text-[var(--fq-color-text-muted)] hover:bg-[var(--fq-color-bg-muted)]/60 hover:text-[var(--fq-color-text-main)]"
                )
              ]}
            >
              <span>Allgemein &amp; Branding</span>
            </button>

            <button
              type="button"
              id="org-tab-billing"
              phx-click="switch_tab"
              phx-value-tab="billing"
              class={[
                "w-full text-left px-3 py-2 rounded-md text-xs font-medium flex items-center justify-between transition-colors cursor-pointer",
                if(@active_tab == :billing,
                  do: "bg-[var(--fq-color-bg-muted)] text-[var(--fq-color-text-main)] font-semibold border-l-2 border-[var(--fq-color-primary)]",
                  else: "text-[var(--fq-color-text-muted)] hover:bg-[var(--fq-color-bg-muted)]/60 hover:text-[var(--fq-color-text-main)]"
                )
              ]}
            >
              <span>Unternehmensdaten &amp; Rechnung</span>
            </button>

            <div class="pt-3 px-3 py-1.5 text-[11px] font-semibold uppercase tracking-wider text-[var(--fq-color-text-muted)]">
              Betrieb &amp; Integration
            </div>

            <button
              type="button"
              id="org-tab-number-ranges"
              phx-click="switch_tab"
              phx-value-tab="number_ranges"
              class={[
                "w-full text-left px-3 py-2 rounded-md text-xs font-medium flex items-center justify-between transition-colors cursor-pointer",
                if(@active_tab == :number_ranges,
                  do: "bg-[var(--fq-color-bg-muted)] text-[var(--fq-color-text-main)] font-semibold border-l-2 border-[var(--fq-color-primary)]",
                  else: "text-[var(--fq-color-text-muted)] hover:bg-[var(--fq-color-bg-muted)]/60 hover:text-[var(--fq-color-text-main)]"
                )
              ]}
            >
              <span>Nummernkreise</span>
              <span class="fq-mono text-[10px] text-[var(--fq-color-text-muted)]"><%= @nr_preview %></span>
            </button>

            <button
              type="button"
              id="org-tab-geo"
              phx-click="switch_tab"
              phx-value-tab="geo"
              class={[
                "w-full text-left px-3 py-2 rounded-md text-xs font-medium flex items-center justify-between transition-colors cursor-pointer",
                if(@active_tab == :geo,
                  do: "bg-[var(--fq-color-bg-muted)] text-[var(--fq-color-text-main)] font-semibold border-l-2 border-[var(--fq-color-primary)]",
                  else: "text-[var(--fq-color-text-muted)] hover:bg-[var(--fq-color-bg-muted)]/60 hover:text-[var(--fq-color-text-main)]"
                )
              ]}
            >
              <span>Karten &amp; Geo-Suche</span>
            </button>

            <button
              :if={@is_owner?}
              type="button"
              id="org-tab-danger"
              phx-click="switch_tab"
              phx-value-tab="danger"
              class={[
                "w-full text-left px-3 py-2 rounded-md text-xs font-medium flex items-center justify-between transition-colors cursor-pointer",
                if(@active_tab == :danger,
                  do: "bg-[#FEF2F2] text-[#991B1B] font-semibold border-l-2 border-[var(--fq-status-danger)]",
                  else: "text-[#991B1B] hover:bg-[#FEF2F2]/60"
                )
              ]}
            >
              <span>Gefahrenzone</span>
            </button>
          </nav>
        </aside>

        <%!-- Right Main Content Area --%>
        <div class="lg:col-span-9 space-y-6">
          <%!-- Panel: Branding (Visible on :general) --%>
          <div class={[@active_tab != :general && "hidden", "space-y-6"]}>
            <.gh_subhead>
              <:title>Firmenlogo &amp; Branding</:title>
              <:description>
                Wird auf Rechnungen, im Hub und bei Einsatzberichten öffentlich angezeigt. Quadratisch 1:1, mind. 512x512px, max. 5MB.
              </:description>
              <:actions>
                <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-[var(--fq-color-bg-muted)] text-[var(--fq-color-text-muted)] border border-[var(--fq-color-border)]">
                  1:1 · Min. 512px · Max. 5MB
                </span>
              </:actions>
            </.gh_subhead>

            <.gh_box body_class="p-6 space-y-4">
              <div class="flex items-center gap-6">
                <div class="relative group">
                  <div class="w-24 h-24 rounded-lg overflow-hidden border-2 border-[var(--fq-color-border-strong)] bg-[var(--fq-color-bg-muted)] flex items-center justify-center shadow-xs">
                    <%= if @logo_url do %>
                      <img src={@logo_url} alt="Firmenlogo" class="w-full h-full object-cover" />
                    <% else %>
                      <span class="text-2xl font-bold text-[var(--fq-color-text-muted)] fq-mono">
                        <%= String.upcase(String.slice(@org.display_name || to_string(@org.handle) || "O", 0, 2)) %>
                      </span>
                    <% end %>
                  </div>
                </div>

                <div class="space-y-2">
                  <%= if @is_owner? do %>
                    <div
                      id="logo-cropper-trigger"
                      phx-hook="ImageCropper"
                      data-modal-id="logo-crop-modal"
                      data-preview-id="logo-crop-preview"
                      data-confirm-btn-id="logo-crop-confirm"
                      data-cancel-btn-id="logo-crop-cancel"
                      data-event="save_logo"
                    >
                      <label class="cursor-pointer inline-flex items-center px-3 py-1.5 border border-[var(--fq-color-border-strong)] rounded text-xs font-semibold text-[var(--fq-color-text-main)] bg-[var(--fq-color-bg-surface)] hover:bg-[var(--fq-color-bg-muted)] shadow-xs transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4 mr-1.5">
                          <path fill-rule="evenodd" d="M1 5.25A2.25 2.25 0 013.25 3h13.5A2.25 2.25 0 0119 5.25v9.5A2.25 2.25 0 0116.75 17H3.25A2.25 2.25 0 011 14.75v-9.5zm1.5 5.81v3.69c0 .414.336.75.75.75h13.5a.75.75 0 00.75-.75v-2.69l-2.22-2.22a.75.75 0 00-1.06 0l-1.91 1.91-3.47-3.47a.75.75 0 00-1.06 0L2.5 11.06zm10.75-4.31a1.25 1.25 0 11-2.5 0 1.25 1.25 0 012.5 0z" clip-rule="evenodd" />
                        </svg>
                        Firmenlogo ändern
                        <input type="file" accept="image/png,image/jpeg,image/webp" class="hidden" />
                      </label>
                    </div>

                    <%= if @logo_url do %>
                      <div>
                        <button
                          type="button"
                          phx-click="remove_logo"
                          data-confirm="Möchten Sie das Firmenlogo wirklich entfernen?"
                          class="cursor-pointer text-xs font-medium text-red-600 hover:text-red-700 hover:underline flex items-center gap-1"
                        >
                          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-3.5 h-3.5">
                            <path fill-rule="evenodd" d="M8.75 1A2.75 2.75 0 006 3.75v.443c-.795.077-1.584.176-2.365.298a.75.75 0 10.23 1.482l.149-.022.841 10.518A2.75 2.75 0 007.596 19h4.807a2.75 2.75 0 002.742-2.53l.841-10.52.149.023a.75.75 0 00.23-1.482A41.03 41.03 0 0014 4.193V3.75A2.75 2.75 0 0011.25 1h-2.5zM10 4c.84 0 1.673.025 2.5.075V3.75c0-.69-.56-1.25-1.25-1.25h-2.5c-.69 0-1.25.56-1.25 1.25v.325C8.327 4.025 9.16 4 10 4zM8.58 7.72a.75.75 0 00-1.5.06l.3 7.5a.75.75 0 101.5-.06l-.3-7.5zm4.34.06a.75.75 0 10-1.5-.06l-.3 7.5a.75.75 0 101.5.06l.3-7.5z" clip-rule="evenodd" />
                          </svg>
                          Logo entfernen
                        </button>
                      </div>
                    <% end %>
                  <% else %>
                    <div class="text-xs text-[var(--fq-color-text-muted)] italic flex items-center gap-1.5 bg-[var(--fq-color-bg-muted)] px-3 py-2 rounded border border-[var(--fq-color-border)]">
                      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4 text-amber-500">
                        <path fill-rule="evenodd" d="M10 1a4.5 4.5 0 00-4.5 4.5V9H5a2 2 0 00-2 2v6a2 2 0 002 2h10a2 2 0 002-2v-6a2 2 0 00-2-2h-.5V5.5A4.5 4.5 0 0010 1zm3 8V5.5a3 3 0 10-6 0V9h6z" clip-rule="evenodd" />
                      </svg>
                      <span>Das Firmenlogo kann nur von Mitgliedern mit Inhaber-Rechten (<code class="fq-mono font-bold">owner</code>) geändert werden.</span>
                    </div>
                  <% end %>
                </div>
              </div>

              <%!-- Modal für interaktiven Bildzuschnitt --%>
              <div id="logo-crop-modal" class="hidden fixed inset-0 z-50 overflow-y-auto bg-black/75 backdrop-blur-xs flex items-center justify-center p-4">
                <div class="bg-[var(--fq-color-bg-surface)] rounded-lg shadow-xl max-w-lg w-full p-6 space-y-4 border border-[var(--fq-color-border)]">
                  <div class="flex items-center justify-between border-b border-[var(--fq-color-border)] pb-3">
                    <h3 class="text-sm font-bold text-[var(--fq-color-text-main)]">Firmenlogo zuschneiden (1:1 Quadrat)</h3>
                    <span class="text-xs text-[var(--fq-color-text-muted)]">Maus/Touch zum Verschieben &amp; Zoomen</span>
                  </div>

                  <div id="logo-crop-preview-wrapper" phx-update="ignore" class="w-full h-80 overflow-hidden bg-black rounded flex items-center justify-center relative">
                    <img id="logo-crop-preview" src="" alt="Vorschau" class="max-h-full block" />
                  </div>

                  <div class="flex justify-end gap-3 pt-3 border-t border-[var(--fq-color-border)]">
                    <button
                      id="logo-crop-cancel"
                      type="button"
                      class="cursor-pointer px-4 py-2 border border-[var(--fq-color-border)] rounded text-xs font-semibold text-[var(--fq-color-text-main)] bg-[var(--fq-color-bg-surface)] hover:bg-[var(--fq-color-bg-muted)]"
                    >
                      Abbrechen
                    </button>
                    <button
                      id="logo-crop-confirm"
                      type="button"
                      class="cursor-pointer px-4 py-2 bg-[var(--fq-color-primary)] hover:bg-[var(--fq-color-primary-hover)] text-white rounded text-xs font-semibold shadow-xs"
                    >
                      Zuschneiden &amp; Speichern
                    </button>
                  </div>
                </div>
              </div>
            </.gh_box>
          </div>

          <%!-- Form: Stammdaten (Section A on :general, Section B on :general and :billing) --%>
          <form
            id="org-stammdaten-form"
            phx-submit="save_org"
            class={[@active_tab not in [:general, :billing] && "hidden", "space-y-6"]}
          >
            <%!-- Section A: Identity & Primary Focus --%>
            <div class={[@active_tab != :general && "hidden"]}>
              <.gh_subhead>
                <:title>Sektion A – Identität &amp; Schwerpunkt</:title>
                <:description>Mandanten-Handle und primärer Geschäftsbereich</:description>
              </.gh_subhead>
              <.gh_box body_class="p-6 space-y-4">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <.input
                    id="org-settings-handle"
                    name="handle"
                    label="Organisations-Handle"
                    prefix="@"
                    monospace={true}
                    value={to_string(@org.handle)}
                    readonly={not @is_owner?}
                  />
                  <.input
                    id="org-settings-focus"
                    name="primary_focus"
                    label="Tätigkeitsschwerpunkt"
                    value={to_string(@org.primary_focus)}
                    readonly={not @is_owner?}
                  />
                </div>
              </.gh_box>
            </div>

            <%!-- Section B: Formal Company Details & Billing (EN 16931 Prep) --%>
            <div>
              <.gh_subhead>
                <:title>Sektion B – Formale Unternehmensdaten &amp; Rechnungsstellung</:title>
                <:description>Stammdaten für GoBD-konforme Abrechnungen und E-Rechnungen (EN 16931)</:description>
              </.gh_subhead>
              <.gh_box body_class="p-6 space-y-4">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <.input
                    id="org-settings-display-name"
                    name="display_name"
                    label="Anzeigename"
                    value={@org.display_name}
                    readonly={not @is_owner?}
                  />
                  <.input
                    id="org-settings-legal-name"
                    name="legal_name"
                    label="Offizieller Firmenname"
                    value={@org.legal_name}
                    readonly={not @is_owner?}
                  />
                  <.input
                    id="org-settings-legal-form"
                    name="legal_form"
                    label="Rechtsform"
                    value={@org.legal_form}
                    readonly={not @is_owner?}
                  />
                  <.input
                    id="org-settings-contact-email"
                    name="contact_email"
                    type="email"
                    label="Kontakt-E-Mail"
                    value={if @org.contact_email, do: to_string(@org.contact_email), else: ""}
                    readonly={not @is_owner?}
                  />
                  <.input
                    id="org-settings-street"
                    name="street_address"
                    label="Straße & Hausnummer"
                    value={@org.street_address}
                    readonly={not @is_owner?}
                  />
                  <.input
                    id="org-settings-postal"
                    name="postal_code"
                    label="Postleitzahl"
                    value={@org.postal_code}
                    readonly={not @is_owner?}
                  />
                  <.input
                    id="org-settings-city"
                    name="city"
                    label="Ort"
                    value={@org.city}
                    readonly={not @is_owner?}
                  />
                  <.input
                    id="org-settings-country"
                    name="country_code"
                    label="Ländercode (ISO)"
                    value={@org.country_code || "DE"}
                    readonly={not @is_owner?}
                  />
                  <.input
                    id="org-settings-tax-id"
                    name="tax_id"
                    label="Steuernummer"
                    monospace={true}
                    value={@org.tax_id}
                    readonly={not @is_owner?}
                  />
                  <.input
                    id="org-settings-vat-id"
                    name="vat_id"
                    label="USt-IdNr."
                    monospace={true}
                    value={@org.vat_id}
                    readonly={not @is_owner?}
                  />
                </div>

                <div :if={@is_owner?} class="pt-2">
                  <.button type="submit">
                    Änderungen speichern
                  </.button>
                </div>
              </.gh_box>
            </div>
          </form>

          <%!-- Section C: Nummernkreise (BusinessKey-Verwaltung) --%>
          <div class={[@active_tab != :number_ranges && "hidden"]}>
            <.gh_subhead>
              <:title>Sektion C – Nummernkreise (Objekt-BusinessKey)</:title>
              <:description>
                Format: <code class="fq-mono">&#123;Präfix&#125;&#123;AktuellerWert&#125;&#123;Suffix&#125;</code>. Unterstützte Datums-Makros in Präfix &amp; Suffix:
                <code class="fq-mono">&#123;&#123;Jahr&#125;&#125;</code>, <code class="fq-mono">&#123;&#123;Monat&#125;&#125;</code>, <code class="fq-mono">&#123;&#123;Tag&#125;&#125;</code>.
              </:description>
              <:actions>
                <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-md bg-[var(--fq-color-bg-muted)] border border-[var(--fq-color-border)]">
                  <span class="text-xs text-[var(--fq-color-text-muted)]">Nächster BusinessKey:</span>
                  <span id="nr-preview-badge" class="fq-mono tabular-nums font-bold text-xs text-[var(--fq-color-primary)]">
                    <%= @nr_preview %>
                  </span>
                </div>
              </:actions>
            </.gh_subhead>

            <form id="org-number-range-form" phx-submit="save_number_range" phx-change="preview_number_range">
              <.gh_box body_class="p-6 space-y-4">
                <div class="grid grid-cols-1 md:grid-cols-5 gap-4">
                  <.input
                    id="nr-prefix"
                    name="prefix"
                    label="Präfix (optional)"
                    monospace={true}
                    value={@number_range.prefix || ""}
                    readonly={not @is_owner?}
                  />
                  <.input
                    id="nr-start-value"
                    name="start_value"
                    type="number"
                    label="Startwert"
                    monospace={true}
                    value={@number_range.start_value}
                    readonly={not @is_owner?}
                  />
                  <.input
                    id="nr-current-value"
                    name="current_value"
                    type="number"
                    label="Aktueller Wert"
                    monospace={true}
                    value={@number_range.current_value}
                    readonly={not @is_owner?}
                  />
                  <.input
                    id="nr-step"
                    name="step"
                    type="number"
                    label="Schrittweite"
                    monospace={true}
                    value={@number_range.step}
                    readonly={not @is_owner?}
                  />
                  <.input
                    id="nr-suffix"
                    name="suffix"
                    label="Suffix (optional)"
                    monospace={true}
                    value={@number_range.suffix || ""}
                    readonly={not @is_owner?}
                  />
                </div>

                <div :if={@is_owner?} class="pt-2">
                  <.button type="submit">
                    Nummernkreis speichern
                  </.button>
                </div>
              </.gh_box>
            </form>
          </div>

          <%!-- Section D: Kartenanbieter & Geo-Suche --%>
          <div class={[@active_tab != :geo && "hidden"]}>
            <.gh_subhead>
              <:title>Sektion D – Kartenanbieter &amp; Geo-Suche</:title>
              <:description>
                Standardmäßig sind OpenStreetMap (Karte) und Nominatim (Geo-Suche) aktiv. Alternativ können Sie Ihr bestehendes HERE Maps Abonnement hinterlegen.
              </:description>
            </.gh_subhead>

            <form id="org-geo-provider-form" phx-submit="save_geo_provider" phx-change="change_geo_provider">
              <.gh_box body_class="p-6 space-y-4">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div class="space-y-1">
                    <label for="org-map-provider" class="block text-sm font-medium text-[var(--fq-color-text-main)]">
                      Kartenanbieter (Map Tiles)
                    </label>
                    <select
                      id="org-map-provider"
                      name="map_provider"
                      disabled={not @is_owner?}
                      class="w-full rounded-md border border-[var(--fq-color-border-strong)] bg-[var(--fq-color-bg-surface)] px-3 text-sm text-[var(--fq-color-text-main)] h-11 lg:h-9 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#2563EB]"
                    >
                      <option value="openstreetmap" selected={@map_provider == "openstreetmap"}>
                        OpenStreetMap (Standard)
                      </option>
                      <option value="here" selected={@map_provider == "here"}>
                        HERE Maps
                      </option>
                    </select>
                  </div>

                  <div class="space-y-1">
                    <label for="org-geocoding-provider" class="block text-sm font-medium text-[var(--fq-color-text-main)]">
                      Geo-Suche &amp; Adressvervollständigung
                    </label>
                    <select
                      id="org-geocoding-provider"
                      name="geocoding_provider"
                      disabled={not @is_owner?}
                      class="w-full rounded-md border border-[var(--fq-color-border-strong)] bg-[var(--fq-color-bg-surface)] px-3 text-sm text-[var(--fq-color-text-main)] h-11 lg:h-9 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#2563EB]"
                    >
                      <option value="nominatim" selected={@geocoding_provider == "nominatim"}>
                        Nominatim / OpenStreetMap (Standard)
                      </option>
                      <option value="here" selected={@geocoding_provider == "here"}>
                        HERE Maps Geocoding &amp; Search API
                      </option>
                    </select>
                  </div>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <.input
                    id="org-here-api-key"
                    name="here_api_key"
                    type="password"
                    label="HERE Maps API-Schlüssel (Pflicht bei Auswahl von HERE Maps)"
                    monospace={true}
                    value={@here_api_key}
                    readonly={not @is_owner?}
                  />
                </div>

                <div :if={@is_owner?} class="flex items-center gap-2 pt-1">
                  <input
                    id="org-apply-all-owned"
                    type="checkbox"
                    name="apply_to_all_owned_orgs"
                    value="true"
                    checked={@apply_to_all_owned_orgs}
                    class="h-4 w-4 rounded border-[var(--fq-color-border-strong)] text-[var(--fq-color-primary)] focus:ring-[#2563EB]"
                  />
                  <label for="org-apply-all-owned" class="text-xs font-medium text-[var(--fq-color-text-main)]">
                    Provider-Konfiguration für alle Organisationen übernehmen, in denen ich Owner bin
                  </label>
                </div>

                <div :if={@is_owner?} class="pt-2">
                  <.button type="submit">
                    Provider-Konfiguration speichern
                  </.button>
                </div>
              </.gh_box>
            </form>
          </div>

          <%!-- Section E: GitHub-Style Danger Zone (Visible for :owner on :general and :danger) --%>
          <div :if={@is_owner?} class={[@active_tab not in [:general, :danger] && "hidden", "space-y-3 pt-2"]}>
            <h2 class="text-base font-bold text-[#991B1B]">
              Sektion E – Gefahrenzone
            </h2>
            <.gh_danger_zone id="org-danger-zone">
              <div class="p-4 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div class="space-y-1">
                  <div class="text-sm font-semibold text-[var(--fq-color-text-main)]">
                    Organisation zur Löschung vormerken
                  </div>
                  <p class="text-xs text-[var(--fq-color-text-muted)]">
                    Die Organisation <span class="fq-mono font-semibold">@<%= @org.handle %></span> wird für 60 Tage gesperrt und anschließend endgültig gelöscht.
                  </p>
                </div>
                <div class="shrink-0">
                  <.button type="button" variant="danger" phx-click="soft_delete_org">
                    Organisation zur Löschung vormerken (60 Tage Frist)
                  </.button>
                </div>
              </div>
            </.gh_danger_zone>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp resolve_logo_url(%{logo_blob: %{variants: %{"512" => key}}}) when is_binary(key),
    do: Storage.public_url(key)

  defp resolve_logo_url(%{logo_blob: %{key: key}}) when is_binary(key),
    do: Storage.public_url(key)

  defp resolve_logo_url(_), do: nil
end
