defmodule Faciqor.Repo.Migrations.CreateAccountsSchema do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"
    execute "CREATE EXTENSION IF NOT EXISTS citext;"

    # 1. users
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :email, :citext, null: false
      add :handle, :citext, null: false
      add :hashed_password, :string
      add :email_confirmed_at, :utc_datetime_usec
      add :deleted_at, :utc_datetime_usec
      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:handle])

    # 2. user_tokens (AshAuthentication)
    create table(:user_tokens, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :jti, :string, null: false
      add :subject, :string, null: false
      add :purpose, :string, null: false
      add :expires_at, :utc_datetime, null: false
      add :extra_data, :map
      add :inserted_at, :utc_datetime_usec, null: false
      add :updated_at, :utc_datetime_usec, null: false
    end

    create unique_index(:user_tokens, [:jti])

    # 3. user_identities (OAuth2)
    create table(:user_identities, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :strategy, :string, null: false
      add :uid, :string, null: false
      add :access_token, :text
      add :refresh_token, :text
      add :upsert_serial, :bigint
      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:user_identities, [:strategy, :uid])

    # 4. api_tokens (PATs for CLI / gRPC)
    create table(:api_tokens, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :token_hash, :string, null: false
      add :last_used_at, :utc_datetime_usec
      add :expires_at, :utc_datetime_usec
      add :revoked_at, :utc_datetime_usec
      add :inserted_at, :utc_datetime_usec, null: false
    end

    create index(:api_tokens, [:token_hash])

    # 5. organizations
    create table(:organizations, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :handle, :citext, null: false
      add :primary_focus, :string, null: false
      add :display_name, :string
      add :legal_name, :string
      add :legal_form, :string
      add :street_address, :string
      add :postal_code, :string
      add :city, :string
      add :country_code, :string, default: "DE"
      add :tax_id, :string
      add :vat_id, :string
      add :contact_email, :citext
      add :deleted_at, :utc_datetime_usec
      add :deletion_reason, :string
      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:organizations, [:handle])

    # 6. organization_memberships
    create table(:organization_memberships, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :organization_id, references(:organizations, type: :uuid, on_delete: :delete_all), null: false
      add :role, :string, null: false
      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:organization_memberships, [:user_id, :organization_id])
  end

  def down do
    drop table(:organization_memberships)
    drop table(:organizations)
    drop table(:api_tokens)
    drop table(:user_identities)
    drop table(:user_tokens)
    drop table(:users)
  end
end
