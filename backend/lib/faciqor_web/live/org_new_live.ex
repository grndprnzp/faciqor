defmodule FaciqorWeb.OrgNewLive do
  use FaciqorWeb, :live_view

  alias Faciqor.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:handle, "")
     |> assign(:primary_focus, :property_manager)
     |> assign(:show_optional, false)
     |> assign(:display_name, "")
     |> assign(:legal_name, "")
     |> assign(:legal_form, "")
     |> assign(:street_address, "")
     |> assign(:postal_code, "")
     |> assign(:city, "")
     |> assign(:country_code, "DE")
     |> assign(:tax_id, "")
     |> assign(:vat_id, "")
     |> assign(:contact_email, "")
     |> assign(:errors, [])}
  end

  @impl true
  def handle_event("select_focus", %{"focus" => focus}, socket) do
    atom_focus =
      case focus do
        "property_owner" -> :property_owner
        "property_manager" -> :property_manager
        "service_provider" -> :service_provider
        _ -> :property_manager
      end

    {:noreply, assign(socket, :primary_focus, atom_focus)}
  end

  def handle_event("toggle_optional", _params, socket) do
    {:noreply, assign(socket, :show_optional, not socket.assigns.show_optional)}
  end

  def handle_event("create_org", params, socket) do
    user = socket.assigns.current_user

    attrs = %{
      handle: params["handle"],
      primary_focus: socket.assigns.primary_focus,
      display_name: blank_to_nil(params["display_name"]),
      legal_name: blank_to_nil(params["legal_name"]),
      legal_form: blank_to_nil(params["legal_form"]),
      street_address: blank_to_nil(params["street_address"]),
      postal_code: blank_to_nil(params["postal_code"]),
      city: blank_to_nil(params["city"]),
      country_code: blank_to_nil(params["country_code"]) || "DE",
      tax_id: blank_to_nil(params["tax_id"]),
      vat_id: blank_to_nil(params["vat_id"]),
      contact_email: blank_to_nil(params["contact_email"])
    }

    case Accounts.Organization
         |> Ash.Changeset.for_create(:create_organization, attrs)
         |> Ash.create(actor: user) do
      {:ok, org} ->
        {:noreply,
         socket
         |> put_flash(:info, "Organisation @#{org.handle} erfolgreich gegründet.")
         |> push_navigate(to: ~p"/orgs/#{org.handle}/settings")}

      {:error, _err} ->
        {:noreply,
         socket
         |> assign(:errors, ["Handle ist bereits vergeben oder ungültig."])
         |> put_flash(:error, "Organisation konnte nicht erstellt werden.")}
    end
  end

  defp blank_to_nil(nil), do: nil
  defp blank_to_nil(""), do: nil
  defp blank_to_nil(str), do: String.trim(str)

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto space-y-6">
      <div>
        <h1 class="text-2xl font-bold text-[var(--fq-color-text-main)]">Neue Organisation gründen</h1>
        <p class="text-sm text-[var(--fq-color-text-muted)]">
          Legen Sie einen neuen Mandanten an. Sie werden automatisch als <span class="font-medium">Owner</span> eingetragen.
        </p>
      </div>

      <form phx-submit="create_org" class="bg-[var(--fq-color-bg-surface)] border border-[var(--fq-color-border)] rounded-lg p-6 space-y-6">
        <%!-- 1. Required: Handle --%>
        <.input
          id="org-handle"
          name="handle"
          label="Organisations-Handle"
          prefix="@"
          monospace={true}
          placeholder="meine-hausverwaltung"
          value={@handle}
          errors={@errors}
          required
        />

        <%!-- 2. Required: Primary Focus Radio Cards --%>
        <div class="space-y-2">
          <label class="block text-sm font-medium text-[var(--fq-color-text-main)]">
            Tätigkeitsschwerpunkt (Pflichtauswahl)
          </label>
          <div class="grid grid-cols-1 gap-3" role="radiogroup">
            <%!-- Option 1: Property Owner --%>
            <button
              type="button"
              role="radio"
              aria-checked={to_string(@primary_focus == :property_owner)}
              phx-click="select_focus"
              phx-value-focus="property_owner"
              class={[
                "text-left p-4 rounded-lg border transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#2563EB]",
                if(@primary_focus == :property_owner,
                  do: "border-[var(--fq-color-primary)] bg-[var(--fq-color-primary-subtle)]",
                  else: "border-[var(--fq-color-border)] bg-[var(--fq-color-bg-surface)] hover:bg-[var(--fq-color-bg-muted)]"
                )
              ]}
            >
              <div class="font-semibold text-sm text-[var(--fq-color-text-main)]">
                Eigentümer / Bestandshalter (:property_owner)
              </div>
              <div class="text-xs text-[var(--fq-color-text-muted)] mt-1">
                „Ich verwalte eigene Liegenschaften oder WEG-Bestände im Direkt- oder Hybridmodell.“
              </div>
            </button>

            <%!-- Option 2: Property Manager --%>
            <button
              type="button"
              role="radio"
              aria-checked={to_string(@primary_focus == :property_manager)}
              phx-click="select_focus"
              phx-value-focus="property_manager"
              class={[
                "text-left p-4 rounded-lg border transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#2563EB]",
                if(@primary_focus == :property_manager,
                  do: "border-[var(--fq-color-primary)] bg-[var(--fq-color-primary-subtle)]",
                  else: "border-[var(--fq-color-border)] bg-[var(--fq-color-bg-surface)] hover:bg-[var(--fq-color-bg-muted)]"
                )
              ]}
            >
              <div class="font-semibold text-sm text-[var(--fq-color-text-main)]">
                Hausverwaltung (:property_manager)
              </div>
              <div class="text-xs text-[var(--fq-color-text-muted)] mt-1">
                „Ich verwalte Immobilienbestände für Dritte, prüfe Belege und übernehme Buchungsstapel.“
              </div>
            </button>

            <%!-- Option 3: Service Provider --%>
            <button
              type="button"
              role="radio"
              aria-checked={to_string(@primary_focus == :service_provider)}
              phx-click="select_focus"
              phx-value-focus="service_provider"
              class={[
                "text-left p-4 rounded-lg border transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#2563EB]",
                if(@primary_focus == :service_provider,
                  do: "border-[var(--fq-color-primary)] bg-[var(--fq-color-primary-subtle)]",
                  else: "border-[var(--fq-color-border)] bg-[var(--fq-color-bg-surface)] hover:bg-[var(--fq-color-bg-muted)]"
                )
              ]}
            >
              <div class="font-semibold text-sm text-[var(--fq-color-text-main)]">
                Dienstleister / KMU (:service_provider)
              </div>
              <div class="text-xs text-[var(--fq-color-text-muted)] mt-1">
                „Ich führe Hausmeister-, Reinigungs-, Grünflächen- oder Handwerksleistungen durch.“
              </div>
            </button>
          </div>
        </div>

        <%!-- 3. Optional Company Details Toggle --%>
        <div>
          <button
            type="button"
            phx-click="toggle_optional"
            class="text-xs font-medium text-[var(--fq-color-primary)] hover:underline"
          >
            <%= if @show_optional, do: "▾ Formale Unternehmensdaten ausblenden", else: "▸ Formale Unternehmensdaten sofort ergänzen" %>
          </button>
        </div>

        <div :if={@show_optional} class="space-y-4 pt-2 border-t border-[var(--fq-color-border)]">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <.input id="org-display-name" name="display_name" label="Anzeigename" value={@display_name} />
            <.input id="org-legal-name" name="legal_name" label="Offizieller Firmenname" value={@legal_name} />
            <.input id="org-legal-form" name="legal_form" label="Rechtsform (z. B. GmbH, WEG)" value={@legal_form} />
            <.input id="org-contact-email" name="contact_email" type="email" label="Rechnungs-/Kontakt-E-Mail" value={@contact_email} />
            <.input id="org-street" name="street_address" label="Straße & Hausnummer" value={@street_address} />
            <.input id="org-postal" name="postal_code" label="PLZ" value={@postal_code} />
            <.input id="org-city" name="city" label="Ort" value={@city} />
            <.input id="org-country" name="country_code" label="Land (ISO-2)" value={@country_code} />
            <.input id="org-tax-id" name="tax_id" label="Steuernummer" monospace={true} value={@tax_id} />
            <.input id="org-vat-id" name="vat_id" label="USt-IdNr." monospace={true} value={@vat_id} />
          </div>
        </div>

        <div class="pt-2 flex justify-end">
          <.button type="submit">
            Organisation gründen
          </.button>
        </div>
      </form>
    </div>
    """
  end
end
