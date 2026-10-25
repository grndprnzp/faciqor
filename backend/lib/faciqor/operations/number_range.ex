defmodule Faciqor.Operations.NumberRange do
  @moduledoc """
  Ash-Ressource für mandantenspezifische Nummernkreise (`number_ranges`) gemäß REQ-M2-FACILITIES § 3.2.
  Unterstützt Präfix/Suffix mit Datums-Makros (`{{Jahr}}`, `{{Monat}}`, `{{Tag}}`),
  Startwert, aktuellen Wert und Schrittweite.
  """
  use Ash.Resource,
    otp_app: :faciqor,
    domain: Faciqor.Operations,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "number_ranges"
    repo Faciqor.Repo
  end

  multitenancy do
    strategy :attribute
    attribute :tenant_id
    global? false
  end

  policies do
    policy action_type(:read) do
      authorize_if {Faciqor.Operations.Checks.HasTenantRole, roles: [:owner, :member, :guest]}
    end

    policy action_type(:create) do
      authorize_if {Faciqor.Operations.Checks.HasTenantRole, roles: [:owner]}
    end

    policy action_type(:update) do
      authorize_if {Faciqor.Operations.Checks.HasTenantRole, roles: [:owner]}
    end

    policy action_type(:destroy) do
      authorize_if {Faciqor.Operations.Checks.HasTenantRole, roles: [:owner]}
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :tenant_id, :uuid do
      allow_nil? false
      public? true
    end

    attribute :entity_type, :atom do
      allow_nil? false
      default :facility
      public? true
      constraints one_of: [:facility]
    end

    attribute :prefix, :string do
      allow_nil? true
      default "OBJ-"
      public? true
    end

    attribute :start_value, :integer do
      allow_nil? false
      default 1000
      public? true
      constraints min: 1
    end

    attribute :current_value, :integer do
      allow_nil? true
      public? true
      constraints min: 0
    end

    attribute :step, :integer do
      allow_nil? false
      default 1
      public? true
      constraints min: 1
    end

    attribute :suffix, :string do
      allow_nil? true
      default ""
      public? true
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :organization, Faciqor.Accounts.Organization do
      source_attribute :tenant_id
      destination_attribute :id
      allow_nil? false
      attribute_writable? true
    end
  end

  actions do
    defaults [:read, :destroy]

    create :create_number_range do
      accept [:entity_type, :prefix, :start_value, :current_value, :step, :suffix]
    end

    update :update_number_range do
      require_atomic? false
      accept [:prefix, :start_value, :current_value, :step, :suffix]

      validate fn changeset, _context ->
        start_val = Ash.Changeset.get_attribute(changeset, :start_value)
        step_val = Ash.Changeset.get_attribute(changeset, :step)

        cond do
          is_integer(start_val) and start_val < 1 ->
            {:error, field: :start_value, message: "Startwert muss mindestens 1 betragen"}

          is_integer(step_val) and step_val < 1 ->
            {:error, field: :step, message: "Schrittweite muss mindestens 1 betragen"}

          true ->
            :ok
        end
      end
    end
  end

  identities do
    identity :unique_tenant_entity_type, [:tenant_id, :entity_type]
  end

  @doc """
  Berechnet den nächsten Zahlenwert, der bei der nächsten Schlüsselvergabe genutzt wird.
  - Wenn `current_value == nil`, wird `start_value` verwendet.
  - Wenn `current_value != nil`, wird `max(current_value + step, start_value)` verwendet.
  """
  def next_numeric_value(%{start_value: start_val, current_value: nil}) do
    start_val || 1000
  end

  def next_numeric_value(%{start_value: start_val, current_value: curr_val, step: step_val}) do
    max((curr_val || 0) + (step_val || 1), start_val || 1)
  end

  @doc """
  Formatiert einen BusinessKey nach dem Muster `{Präfix}{AktuellerWert}{Suffix}`
  inklusive Auflösung der Makros `{{Jahr}}`, `{{Monat}}` und `{{Tag}}`.
  """
  def format_key(prefix, numeric_value, suffix, %Date{} = date \\ Date.utc_today()) do
    resolved_prefix = resolve_macros(prefix || "", date)
    resolved_suffix = resolve_macros(suffix || "", date)
    "#{resolved_prefix}#{numeric_value}#{resolved_suffix}"
  end

  @doc """
  Erzeugt eine Vorschau auf den nächsten BusinessKey für diesen Nummernkreis.
  """
  def preview_next_key(nr_or_attrs, date \\ Date.utc_today())

  def preview_next_key(%__MODULE__{} = nr, %Date{} = date) do
    next_val = next_numeric_value(nr)
    format_key(nr.prefix, next_val, nr.suffix, date)
  end

  def preview_next_key(attrs, %Date{} = date) when is_map(attrs) do
    start_val = Map.get(attrs, :start_value) || Map.get(attrs, "start_value") || 1000
    curr_val = Map.get(attrs, :current_value) || Map.get(attrs, "current_value")
    step_val = Map.get(attrs, :step) || Map.get(attrs, "step") || 1
    prefix = Map.get(attrs, :prefix) || Map.get(attrs, "prefix") || ""
    suffix = Map.get(attrs, :suffix) || Map.get(attrs, "suffix") || ""

    next_val =
      next_numeric_value(%{
        start_value: start_val,
        current_value: curr_val,
        step: step_val
      })

    format_key(prefix, next_val, suffix, date)
  end

  def resolve_macros(nil, _date), do: ""

  def resolve_macros(str, %Date{year: year, month: month, day: day}) when is_binary(str) do
    year_str = Integer.to_string(year)
    month_str = month |> Integer.to_string() |> String.pad_leading(2, "0")
    day_str = day |> Integer.to_string() |> String.pad_leading(2, "0")

    str
    |> String.replace("{{Jahr}}", year_str)
    |> String.replace("{{Monat}}", month_str)
    |> String.replace("{{Tag}}", day_str)
  end
end
