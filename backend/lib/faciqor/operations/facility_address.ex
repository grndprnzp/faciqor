defmodule Faciqor.Operations.FacilityAddress do
  @moduledoc """
  Ash-Ressource für die einzelnen Hausnummern / Teiladressen (`facility_addresses`) eines Objekts.
  Jede Teiladresse speichert ihre eigenen `Decimal`-Koordinaten (`latitude`, `longitude`),
  die in PostgreSQL via Trigger in die PostGIS-Spalte `location GEOGRAPHY(Point, 4326)` synchronisiert werden.
  """
  use Ash.Resource,
    otp_app: :faciqor,
    domain: Faciqor.Operations,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "facility_addresses"
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
      authorize_if {Faciqor.Operations.Checks.HasTenantRole, roles: [:owner, :member]}
    end

    policy action_type(:update) do
      authorize_if {Faciqor.Operations.Checks.HasTenantRole, roles: [:owner, :member]}
    end

    policy action_type(:destroy) do
      authorize_if {Faciqor.Operations.Checks.HasTenantRole, roles: [:owner, :member]}
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :tenant_id, :uuid do
      allow_nil? false
      public? true
    end

    attribute :facility_id, :uuid do
      allow_nil? false
      public? true
    end

    attribute :street, :string do
      allow_nil? false
      public? true
    end

    attribute :house_number, :string do
      allow_nil? false
      public? true
    end

    attribute :house_number_numeric, :integer do
      allow_nil? false
      default 0
      public? true
    end

    attribute :house_number_suffix, :string do
      allow_nil? true
      public? true
    end

    attribute :postal_code, :string do
      allow_nil? false
      public? true
    end

    attribute :city, :string do
      allow_nil? false
      public? true
    end

    attribute :country_code, :string do
      allow_nil? false
      default "DE"
      public? true
    end

    attribute :latitude, :decimal do
      allow_nil? false
      public? true
    end

    attribute :longitude, :decimal do
      allow_nil? false
      public? true
    end

    attribute :is_primary, :boolean do
      allow_nil? false
      default false
      public? true
    end

    attribute :sort_order, :integer do
      allow_nil? false
      default 0
      public? true
    end

    attribute :provider_place_id, :string do
      allow_nil? true
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

    belongs_to :facility, Faciqor.Operations.Facility do
      source_attribute :facility_id
      destination_attribute :id
      allow_nil? false
      attribute_writable? true
    end
  end

  actions do
    defaults [:read, :destroy]

    create :create_facility_address do
      accept [
        :facility_id,
        :street,
        :house_number,
        :house_number_numeric,
        :house_number_suffix,
        :postal_code,
        :city,
        :country_code,
        :latitude,
        :longitude,
        :is_primary,
        :sort_order,
        :provider_place_id
      ]
    end
  end
end
