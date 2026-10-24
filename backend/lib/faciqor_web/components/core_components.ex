defmodule FaciqorWeb.CoreComponents do
  @moduledoc """
  Faciqor Hub Core UI Components strictly adhering to `design/tokens.json`,
  `backend/assets/css/app.css` (`--fq-*` CSS variables), Desktop-First sizing,
  and GoBD readonly states.
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  @doc """
  Renders a button with Desktop-First height (`h-11 lg:h-9`) and focus ring (`#2563EB`).
  """
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :variant, :string, default: "primary", values: ~w(primary secondary danger ghost)
  attr :disabled, :boolean, default: false
  attr :rest, :global, include: ~w(form name value)

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      disabled={@disabled}
      class={[
        "inline-flex items-center justify-center rounded-md px-4 font-medium transition-colors",
        "h-11 lg:h-9 text-sm",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#2563EB] focus-visible:ring-offset-1",
        "disabled:opacity-50 disabled:cursor-not-allowed",
        variant_classes(@variant),
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  defp variant_classes("primary"),
    do: "bg-[var(--fq-color-primary)] text-white hover:bg-[var(--fq-color-primary-hover)]"

  defp variant_classes("secondary"),
    do: "bg-[var(--fq-color-bg-surface)] text-[var(--fq-color-text-main)] border border-[var(--fq-color-border-strong)] hover:bg-[var(--fq-color-bg-muted)]"

  defp variant_classes("danger"),
    do: "bg-[var(--fq-status-danger)] text-white hover:opacity-90"

  defp variant_classes("ghost"),
    do: "bg-transparent text-[var(--fq-color-text-muted)] hover:bg-[var(--fq-color-bg-muted)] hover:text-[var(--fq-color-text-main)]"

  @doc """
  Renders an input with label, error messages, optional monospace (`fq-mono tabular-nums`),
  and GoBD-compliant `readonly` state (full text contrast `#0F172A`, muted background `#F1F5F9`, lock icon).
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any
  attr :type, :string, default: "text"
  attr :field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form"
  attr :errors, :list, default: []
  attr :readonly, :boolean, default: false
  attr :monospace, :boolean, default: false
  attr :prefix, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength multiple pattern placeholder required rows size step)

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(assigns) do
    ~H"""
    <div class="space-y-1">
      <div :if={@label} class="flex items-center justify-between">
        <label for={@id} class="block text-sm font-medium text-[var(--fq-color-text-main)]">
          <%= @label %>
        </label>
        <span :if={@readonly} class="inline-flex items-center gap-1 text-xs text-[var(--fq-color-text-muted)]" title="Schreibgeschützt (GoBD / Rollenberechtigung)">
          <svg class="h-3.5 w-3.5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
            <path fill-rule="evenodd" d="M10 1a4.5 4.5 0 00-4.5 4.5V9H5a2 2 0 00-2 2v6a2 2 0 002 2h10a2 2 0 002-2v-6a2 2 0 00-2-2h-.5V5.5A4.5 4.5 0 0010 1zm3 8V5.5a3 3 0 10-6 0V9h6z" clip-rule="evenodd" />
          </svg>
          <span>Schreibgeschützt</span>
        </span>
      </div>
      <div class="relative flex items-center">
        <span
          :if={@prefix}
          class="inline-flex items-center h-11 lg:h-9 px-3 rounded-l-md border border-r-0 border-[var(--fq-color-border)] bg-[var(--fq-color-bg-muted)] text-[var(--fq-color-text-muted)] fq-mono text-sm"
        >
          <%= @prefix %>
        </span>
        <input
          type={@type}
          name={@name}
          id={@id}
          value={Phoenix.HTML.Form.normalize_value(@type, @value)}
          readonly={@readonly}
          class={[
            "block w-full h-11 lg:h-9 px-3 text-sm border transition-colors",
            if(@prefix, do: "rounded-r-md", else: "rounded-md"),
            if(@monospace, do: "fq-mono tabular-nums", else: ""),
            if(@readonly,
              do: "bg-[#F1F5F9] text-[#0F172A] border-[var(--fq-color-border)] cursor-default",
              else: "bg-[var(--fq-color-bg-surface)] text-[var(--fq-color-text-main)] border-[var(--fq-color-border-strong)] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#2563EB]"
            ),
            @errors != [] && "border-[var(--fq-status-danger)]",
            @class
          ]}
          {@rest}
        />
      </div>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  @doc """
  Renders an error message under form inputs.
  """
  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <p class="mt-1 text-xs text-[#991B1B] flex items-center gap-1">
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  @doc """
  Renders a BetrKV legal classification badge using exclusively reserved colors (`--fq-betrkv-*`).
  """
  attr :category, :atom, required: true, values: [:allocatable, :maintenance, :admin]

  def betrkv_badge(assigns) do
    ~H"""
    <span class={[
      "inline-flex items-center px-2 py-0.5 rounded text-xs font-medium border",
      betrkv_classes(@category)
    ]}>
      <%= betrkv_label(@category) %>
    </span>
    """
  end

  defp betrkv_classes(:allocatable),
    do: "bg-[var(--fq-betrkv-allocatable-bg)] text-[var(--fq-betrkv-allocatable-text)] border-[var(--fq-betrkv-allocatable-border)]"

  defp betrkv_classes(:maintenance),
    do: "bg-[var(--fq-betrkv-maintenance-bg)] text-[var(--fq-betrkv-maintenance-text)] border-[var(--fq-betrkv-maintenance-border)]"

  defp betrkv_classes(:admin),
    do: "bg-[var(--fq-betrkv-admin-bg)] text-[var(--fq-betrkv-admin-text)] border-[var(--fq-betrkv-admin-border)]"

  defp betrkv_label(:allocatable), do: "§ 2 Nr. 14 BetrKV (Umlagefähig)"
  defp betrkv_label(:maintenance), do: "§ 1 Abs. 2 BetrKV (Instandhaltung)"
  defp betrkv_label(:admin), do: "§ 1 Abs. 2 Nr. 1 BetrKV (Verwaltung)"

  @doc """
  Renders a verification or role status badge.
  """
  attr :status, :atom, required: true, values: [:verified, :unverified, :owner, :member, :guest]

  def status_badge(assigns) do
    ~H"""
    <span class={[
      "inline-flex items-center px-2 py-0.5 rounded text-xs font-medium",
      status_badge_classes(@status)
    ]}>
      <%= status_badge_label(@status) %>
    </span>
    """
  end

  defp status_badge_classes(:verified), do: "bg-[#ECFDF5] text-[#065F46]"
  defp status_badge_classes(:unverified), do: "bg-[#FFFBEB] text-[#92400E]"
  defp status_badge_classes(:owner), do: "bg-[#EFF6FF] text-[#1E40AF]"
  defp status_badge_classes(:member), do: "bg-[#F1F5F9] text-[#475569]"
  defp status_badge_classes(:guest), do: "bg-[#F1F5F9] text-[#475569]"

  defp status_badge_label(:verified), do: "Verifiziert"
  defp status_badge_label(:unverified), do: "Unbestätigt"
  defp status_badge_label(:owner), do: "Owner"
  defp status_badge_label(:member), do: "Member"
  defp status_badge_label(:guest), do: "Guest"

  @doc """
  Renders a proof status badge for field service records.
  """
  attr :verified, :boolean, default: false

  def proof_badge(assigns) do
    ~H"""
    <span class={[
      "inline-flex items-center px-2 py-0.5 rounded text-xs font-medium fq-mono",
      if(@verified, do: "bg-[#ECFDF5] text-[#065F46]", else: "bg-[#FFFBEB] text-[#92400E]")
    ]}>
      <%= if @verified, do: "SHA-256 Verified", else: "Pending Proof" %>
    </span>
    """
  end

  @doc """
  Renders a high-density ERP data table.
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  slot :col, required: true do
    attr :label, :string
    attr :numeric, :boolean
  end
  slot :action

  def table(assigns) do
    ~H"""
    <div class="overflow-x-auto border border-[var(--fq-color-border)] rounded-lg bg-[var(--fq-color-bg-surface)]">
      <table class="min-w-full divide-y divide-[var(--fq-color-border)] text-sm">
        <thead class="bg-[var(--fq-color-bg-muted)]">
          <tr>
            <th
              :for={col <- @col}
              class={[
                "px-4 py-2.5 font-medium text-[var(--fq-color-text-muted)]",
                if(col[:numeric], do: "text-right", else: "text-left")
              ]}
            >
              <%= col[:label] %>
            </th>
            <th :if={@action != []} class="px-4 py-2.5 text-right font-medium text-[var(--fq-color-text-muted)]">
              Aktion
            </th>
          </tr>
        </thead>
        <tbody id={@id} class="divide-y divide-[var(--fq-color-border)]">
          <tr :for={row <- @rows} class="hover:bg-[var(--fq-color-bg-app)]">
            <td
              :for={col <- @col}
              class={[
                "px-4 py-2.5 text-[var(--fq-color-text-main)]",
                if(col[:numeric], do: "text-right fq-mono tabular-nums", else: "text-left")
              ]}
            >
              <%= render_slot(col, row) %>
            </td>
            <td :if={@action != []} class="px-4 py-2.5 text-right">
              <%= render_slot(@action, row) %>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  def translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end
end
