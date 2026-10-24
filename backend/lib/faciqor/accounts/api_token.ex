defmodule Faciqor.Accounts.ApiToken do
  use Ash.Resource,
    otp_app: :faciqor,
    domain: Faciqor.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "api_tokens"
    repo Faciqor.Repo
  end

  policies do
    # Only verified users can create API tokens (email_confirmed_at != nil)
    policy action_type(:create) do
      authorize_if expr(not is_nil(^actor(:email_confirmed_at)))
    end

    policy action_type(:read) do
      authorize_if expr(user_id == ^actor(:id))
    end

    policy action_type(:update) do
      authorize_if expr(user_id == ^actor(:id))
    end

    policy action_type(:destroy) do
      authorize_if expr(user_id == ^actor(:id))
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :token_hash, :string do
      allow_nil? false
      sensitive? true
    end

    attribute :last_used_at, :utc_datetime_usec do
      public? true
    end

    attribute :expires_at, :utc_datetime_usec do
      public? true
    end

    attribute :revoked_at, :utc_datetime_usec do
      public? true
    end

    create_timestamp :inserted_at
  end

  relationships do
    belongs_to :user, Faciqor.Accounts.User do
      allow_nil? false
      attribute_writable? true
    end
  end

  actions do
    defaults [:read, :destroy]

    create :generate do
      accept [:name, :expires_at]
      argument :token_plain, :string, allow_nil?: false, sensitive?: true

      change relate_actor(:user)

      change fn changeset, _context ->
        plain = Ash.Changeset.get_argument(changeset, :token_plain)
        hash = :crypto.hash(:sha256, plain) |> Base.encode16(case: :lower)
        Ash.Changeset.change_attribute(changeset, :token_hash, hash)
      end
    end

    update :revoke do
      require_atomic? false
      change set_attribute(:revoked_at, &DateTime.utc_now/0)
    end

    update :touch_last_used do
      require_atomic? false
      change set_attribute(:last_used_at, &DateTime.utc_now/0)
    end
  end
end
