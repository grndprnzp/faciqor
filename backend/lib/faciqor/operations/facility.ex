defmodule Faciqor.Operations.Facility do
  @moduledoc """
  Ash-Ressource für Objekte/Liegenschaften (`facilities`) gemäß REQ-M2-FACILITIES § 3.3.
  Besitzt einen pro Organisation eindeutigen, nach Anlage unveränderlichen `business_key`,
  einen deterministisch aus den Teiladressen berechneten `title` sowie eine PostGIS Geofence-Zone.
  """
  use Ash.Resource,
    otp_app: :faciqor,
    domain: Faciqor.Operations,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "facilities"
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
      authorize_if {Faciqor.Operations.Checks.HasTenantRole, roles: [:owner]}
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :tenant_id, :uuid do
      allow_nil? false
      public? true
    end

    attribute :business_key, :ci_string do
      allow_nil? false
      public? true
    end

    attribute :title, :string do
      allow_nil? false
      public? true
    end

    attribute :geofence_wkt, :string do
      allow_nil? false
      public? true
    end

    attribute :geofence_polygon, {:array, :map} do
      allow_nil? false
      default []
      public? true
    end

    attribute :geofence_radius_meters, :integer do
      allow_nil? false
      default 50
      public? true
    end

    attribute :archived_at, :utc_datetime_usec do
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

    has_many :addresses, Faciqor.Operations.FacilityAddress do
      destination_attribute :facility_id
      sort sort_order: :asc, house_number_numeric: :asc
    end
  end

  actions do
    defaults [:read, :destroy]

    create :create_facility_record do
      accept [
        :business_key,
        :title,
        :geofence_wkt,
        :geofence_polygon,
        :geofence_radius_meters
      ]
    end

    update :update_facility_record do
      require_atomic? false
      # business_key ist bewusst NICHT in accept enthalten (nach Anlage unveränderlich!)
      accept [
        :title,
        :geofence_wkt,
        :geofence_polygon,
        :geofence_radius_meters
      ]
    end

    update :archive_facility do
      require_atomic? false
      change set_attribute(:archived_at, &DateTime.utc_now/0)
    end

    update :unarchive_facility do
      require_atomic? false
      change set_attribute(:archived_at, nil)
    end
  end

  identities do
    identity :unique_tenant_business_key, [:tenant_id, :business_key]
  end
end
