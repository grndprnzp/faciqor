defmodule FaciqorWeb.OrgSettingsLive do
  use FaciqorWeb, :live_view

  alias Faciqor.Accounts

  @impl true
  def mount(%{"handle" => handle}, _session, socket) do
    user = socket.assigns.current_user

    clean_handle = handle |> to_string() |> String.trim_leading("@")

    case Accounts.get_organization_by_id_or_handle(clean_handle, actor: user) do
      {:ok, org} ->
        role = find_user_role(org, user.id)
        is_owner? = role == :owner

        {:ok,
         socket
         |> assign(:org, org)
         |> assign(:current_org, org)
         |> assign(:my_role, role)
         |> assign(:is_owner?, is_owner?)}

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
end
