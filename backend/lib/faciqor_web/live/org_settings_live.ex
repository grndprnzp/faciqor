defmodule FaciqorWeb.OrgSettingsLive do
  use FaciqorWeb, :live_view

  alias Faciqor.Accounts
  alias Faciqor.Media
  alias Faciqor.Media.ImageProcessing
  alias Faciqor.Media.Storage
  alias Faciqor.Media.Workers.ProcessImageVariants

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

        {:ok,
         socket
         |> assign(:org, org)
         |> assign(:current_org, org)
         |> assign(:my_role, role)
         |> assign(:is_owner?, is_owner?)
         |> assign(:logo_url, logo_url)}

      {:error, _} ->
        {:ok,
         socket
         |> put_flash(:error, "Organisation nicht gefunden oder kein Zugriff.")
         |> push_navigate(to: ~p"/dashboard")}
    end
  end

  @impl true
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

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="flex items-center justify-between">
        <div>
          <div class="flex items-center gap-2">
            <h1 class="text-2xl font-bold text-[var(--fq-color-text-main)] fq-mono">
              @<%= @org.handle %>
            </h1>
            <.status_badge status={@my_role} />
          </div>
          <p class="text-sm text-[var(--fq-color-text-muted)]">
            Organisations-Stammdaten &amp; Mandanten-Konfiguration
          </p>
        </div>
      </div>

      <%!-- Card: Firmenlogo & Branding --%>
      <section class="bg-[var(--fq-color-bg-surface)] border border-[var(--fq-color-border)] rounded-lg p-6 space-y-4">
        <div class="flex items-start justify-between flex-wrap gap-4">
          <div>
            <h2 class="text-base font-bold text-[var(--fq-color-text-main)]">Firmenlogo &amp; Branding</h2>
            <p class="text-xs text-[var(--fq-color-text-muted)]">
              Wird auf Rechnungen, im Hub und bei Einsatzberichten öffentlich angezeigt. Quadratisch 1:1, mind. 512x512px, max. 5MB.
            </p>
          </div>
          <div class="flex items-center gap-2">
            <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-[var(--fq-color-bg-muted)] text-[var(--fq-color-text-muted)] border border-[var(--fq-color-border)]">
              1:1 Quadrat
            </span>
            <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-[var(--fq-color-bg-muted)] text-[var(--fq-color-text-muted)] border border-[var(--fq-color-border)]">
              Min. 512px
            </span>
            <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-[var(--fq-color-bg-muted)] text-[var(--fq-color-text-muted)] border border-[var(--fq-color-border)]">
              Max. 5MB
            </span>
          </div>
        </div>

        <div class="flex items-center gap-6 pt-2">
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
      </section>

      <form phx-submit="save_org" class="space-y-6">
        <%!-- Section A: Identity & Primary Focus --%>
        <section class="bg-[var(--fq-color-bg-surface)] border border-[var(--fq-color-border)] rounded-lg p-6 space-y-4">
          <h2 class="text-base font-bold text-[var(--fq-color-text-main)]">
            Sektion A – Identität &amp; Schwerpunkt
          </h2>
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
        </section>

        <%!-- Section B: Formal Company Details & Billing (EN 16931 Prep) --%>
        <section class="bg-[var(--fq-color-bg-surface)] border border-[var(--fq-color-border)] rounded-lg p-6 space-y-4">
          <h2 class="text-base font-bold text-[var(--fq-color-text-main)]">
            Sektion B – Formale Unternehmensdaten &amp; Rechnungsstellung
          </h2>
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
        </section>
      </form>

      <%!-- Section C: Danger Zone (Visible only for :owner) --%>
      <section
        :if={@is_owner?}
        id="org-danger-zone"
        class="bg-[var(--fq-color-bg-surface)] border-2 border-[var(--fq-status-danger)] rounded-lg p-6 space-y-4"
      >
        <h2 class="text-base font-bold text-[#991B1B]">
          Sektion C – Gefahrenzone
        </h2>
        <p class="text-xs text-[var(--fq-color-text-muted)]">
          Die Organisation wird für 60 Tage gesperrt und anschließend endgültig gelöscht.
        </p>
        <.button type="button" variant="danger" phx-click="soft_delete_org">
          Organisation zur Löschung vormerken (60 Tage Frist)
        </.button>
      </section>
    </div>
    """
  end

  defp resolve_logo_url(%{logo_blob: %{variants: %{"512" => key}}}) when is_binary(key),
    do: Storage.public_url(key)

  defp resolve_logo_url(%{logo_blob: %{key: key}}) when is_binary(key),
    do: Storage.public_url(key)

  defp resolve_logo_url(_), do: nil
end
