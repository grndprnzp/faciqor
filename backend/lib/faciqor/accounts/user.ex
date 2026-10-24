defmodule Faciqor.Accounts.User do
  use Ash.Resource,
    otp_app: :faciqor,
    domain: Faciqor.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshAuthentication]

  postgres do
    table "users"
    repo Faciqor.Repo
  end

  authentication do
    tokens do
      enabled? true
      token_resource Faciqor.Accounts.Token
      signing_secret fn _, _ ->
        case Application.fetch_env(:faciqor, :token_signing_secret) do
          {:ok, secret} -> {:ok, secret}
          :error -> {:ok, "temporary_dev_secret_at_least_32_characters_long_1234567890"}
        end
      end
    end

    strategies do
      password :password do
        identity_field :email
        hashed_password_field :hashed_password
        sign_in_tokens_enabled? true
      end

      magic_link do
        identity_field :email
        sender fn user, token, _opts ->
          require Logger
          Logger.info("[MagicLink] Token for #{user.email}: #{token}")
        end
      end

      google do
        client_id fn _, _ -> {:ok, System.get_env("GOOGLE_CLIENT_ID", "dummy_google_client_id")} end
        client_secret fn _, _ -> {:ok, System.get_env("GOOGLE_CLIENT_SECRET", "dummy_google_client_secret")} end
        redirect_uri fn _, _ -> {:ok, "http://localhost:4000/auth/user/google/callback"} end
        identity_resource Faciqor.Accounts.UserIdentity
      end
    end
  end

  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end

    policy action_type(:create) do
      authorize_if always()
    end

    policy action_type(:read) do
      authorize_if expr(id == ^actor(:id))
    end

    policy action_type(:update) do
      authorize_if expr(id == ^actor(:id))
    end

    policy action_type(:destroy) do
      authorize_if expr(id == ^actor(:id))
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :email, :ci_string do
      allow_nil? false
      public? true
    end

    attribute :handle, :ci_string do
      allow_nil? false
      public? true
      constraints match: ~r/^[a-z0-9][a-z0-9_-]{2,30}$/
    end

    attribute :hashed_password, :string do
      allow_nil? true
      sensitive? true
    end

    attribute :email_confirmed_at, :utc_datetime_usec do
      allow_nil? true
      public? true
    end

    attribute :deleted_at, :utc_datetime_usec do
      allow_nil? true
      public? true
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :email_verified?, :boolean, expr(not is_nil(email_confirmed_at))
    calculate :verification_grace_expired?, :boolean, expr(is_nil(email_confirmed_at) and inserted_at < ago(14, :day))
    calculate :purge_at, :utc_datetime_usec, expr(datetime_add(deleted_at, 60, :day))
  end

  relationships do
    has_many :memberships, Faciqor.Accounts.OrganizationMembership
    has_many :organizations, Faciqor.Accounts.Organization, through: [:memberships, :organization]
    has_many :api_tokens, Faciqor.Accounts.ApiToken
    has_many :identities, Faciqor.Accounts.UserIdentity
  end

  actions do
    defaults [:read, :destroy]

    create :register_with_password do
      argument :email, :ci_string, allow_nil?: false
      argument :password, :string, allow_nil?: false, sensitive?: true
      argument :handle, :ci_string, allow_nil?: true

      change set_attribute(:email, arg(:email))
      change set_attribute(:handle, arg(:handle))
      change Faciqor.Accounts.Changes.GenerateDefaultHandle
      change AshAuthentication.Strategy.Password.HashPasswordChange
    end

    create :sign_in_with_magic_link do
      argument :email, :ci_string, allow_nil?: false
      upsert? true
      upsert_identity :unique_email
      upsert_fields [:email_confirmed_at]

      change set_attribute(:email, arg(:email))
      change set_attribute(:email_confirmed_at, &DateTime.utc_now/0)
      change Faciqor.Accounts.Changes.GenerateDefaultHandle
    end

    create :register_with_google do
      argument :user_info, :map, allow_nil?: false
      argument :oauth_tokens, :map, allow_nil?: false
      upsert? true
      upsert_identity :unique_email
      upsert_fields [:email_confirmed_at]

      change AshAuthentication.GenerateTokenChange
      change AshAuthentication.Strategy.OAuth2.IdentityChange

      change fn changeset, _ ->
        user_info = Ash.Changeset.get_argument(changeset, :user_info)
        email = Map.get(user_info, "email") || Map.get(user_info, :email)

        changeset
        |> Ash.Changeset.change_attribute(:email, email)
        |> Ash.Changeset.change_attribute(:email_confirmed_at, DateTime.utc_now())
      end

      change Faciqor.Accounts.Changes.GenerateDefaultHandle
    end

    update :update_profile do
      accept [:handle]
      require_atomic? false
    end

    update :confirm_email do
      require_atomic? false
      change set_attribute(:email_confirmed_at, &DateTime.utc_now/0)
    end

    update :soft_delete_user do
      require_atomic? false
      change set_attribute(:deleted_at, &DateTime.utc_now/0)
      change Faciqor.Accounts.Changes.CascadeSoftDeleteToOrphanedOrgs
    end

    update :restore_user do
      require_atomic? false
      change set_attribute(:deleted_at, nil)
      change Faciqor.Accounts.Changes.RestoreOrphanedOrgs
    end
  end

  identities do
    identity :unique_email, [:email]
    identity :unique_handle, [:handle]
  end
end
