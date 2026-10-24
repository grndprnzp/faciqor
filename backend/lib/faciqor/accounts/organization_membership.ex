defmodule Faciqor.Accounts.OrganizationMembership do
  use Ash.Resource,
    otp_app: :faciqor,
    domain: Faciqor.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "organization_memberships"
    repo Faciqor.Repo
  end

  policies do
    # Members can view memberships in their organizations
    policy action_type(:read) do
      authorize_if expr(user_id == ^actor(:id))
      authorize_if expr(organization.memberships.user_id == ^actor(:id))
    end

    # Only owners can add/manage memberships (or creation change)
    policy action_type(:create) do
      authorize_if always()
    end

    policy action_type(:update) do
      authorize_if expr(organization.memberships.user_id == ^actor(:id) and organization.memberships.role == :owner)
    end

    policy action_type(:destroy) do
      authorize_if expr(organization.memberships.user_id == ^actor(:id) and organization.memberships.role == :owner)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :role, :atom do
      allow_nil? false
      public? true
      constraints one_of: [:owner, :member, :guest]
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :user, Faciqor.Accounts.User do
      allow_nil? false
      attribute_writable? true
    end

    belongs_to :organization, Faciqor.Accounts.Organization do
      allow_nil? false
      attribute_writable? true
    end
  end

  actions do
    defaults [:read, :destroy]

    create :create_membership do
      accept [:role]
      argument :user_id, :uuid, allow_nil?: false
      argument :organization_id, :uuid, allow_nil?: false

      change set_attribute(:user_id, arg(:user_id))
      change set_attribute(:organization_id, arg(:organization_id))
    end
  end

  identities do
    identity :unique_membership, [:user_id, :organization_id]
  end
end
