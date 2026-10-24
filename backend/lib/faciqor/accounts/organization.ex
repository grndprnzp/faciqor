defmodule Faciqor.Accounts.Organization do
  use Ash.Resource,
    otp_app: :faciqor,
    domain: Faciqor.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "organizations"
    repo Faciqor.Repo
  end

  policies do
    policy action_type(:create) do
      authorize_if actor_present()
    end

    policy action_type(:read) do
      authorize_if expr(memberships.user_id == ^actor(:id))
    end

    policy action_type(:update) do
      authorize_if expr(memberships.user_id == ^actor(:id) and memberships.role == :owner)
    end

    policy action_type(:destroy) do
      authorize_if expr(memberships.user_id == ^actor(:id) and memberships.role == :owner)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :handle, :ci_string do
      allow_nil? false
      public? true
      constraints match: ~r/^[a-z0-9][a-z0-9_-]{2,30}$/
    end

    attribute :primary_focus, :atom do
      allow_nil? false
      public? true
      constraints one_of: [:property_owner, :property_manager, :service_provider]
    end

    attribute :display_name, :string, public?: true
    attribute :legal_name, :string, public?: true
    attribute :legal_form, :string, public?: true
    attribute :street_address, :string, public?: true
    attribute :postal_code, :string, public?: true
    attribute :city, :string, public?: true
    attribute :country_code, :string, default: "DE", public?: true
    attribute :tax_id, :string, public?: true
    attribute :vat_id, :string, public?: true
    attribute :contact_email, :ci_string, public?: true

    attribute :deleted_at, :utc_datetime_usec, public?: true

    attribute :deletion_reason, :atom do
      public? true
      constraints one_of: [:manual_by_owner, :orphaned_by_last_owner]
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :memberships, Faciqor.Accounts.OrganizationMembership
    has_many :users, Faciqor.Accounts.User, through: [:memberships, :user]
  end

  actions do
    defaults [:read, :destroy]

    create :create_organization do
      accept [
        :handle,
        :primary_focus,
        :display_name,
        :legal_name,
        :legal_form,
        :street_address,
        :postal_code,
        :city,
        :country_code,
        :tax_id,
        :vat_id,
        :contact_email
      ]

      change Faciqor.Accounts.Changes.CreateOwnerMembership
    end

    update :update_organization do
      require_atomic? false

      accept [
        :handle,
        :primary_focus,
        :display_name,
        :legal_name,
        :legal_form,
        :street_address,
        :postal_code,
        :city,
        :country_code,
        :tax_id,
        :vat_id,
        :contact_email
      ]
    end

    update :soft_delete do
      require_atomic? false
      argument :reason, :atom, default: :manual_by_owner
      change set_attribute(:deleted_at, &DateTime.utc_now/0)
      change set_attribute(:deletion_reason, arg(:reason))
    end

    update :restore_org do
      require_atomic? false
      change set_attribute(:deleted_at, nil)
      change set_attribute(:deletion_reason, nil)
    end
  end

  identities do
    identity :unique_handle, [:handle]
  end
end
