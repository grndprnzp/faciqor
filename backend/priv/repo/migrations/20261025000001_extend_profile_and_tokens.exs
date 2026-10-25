defmodule Faciqor.Repo.Migrations.ExtendProfileAndTokens do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE users ADD COLUMN IF NOT EXISTS display_name VARCHAR(255);"
    execute "ALTER TABLE users ADD COLUMN IF NOT EXISTS first_name VARCHAR(255);"
    execute "ALTER TABLE users ADD COLUMN IF NOT EXISTS last_name VARCHAR(255);"
    execute "ALTER TABLE users ADD COLUMN IF NOT EXISTS phone VARCHAR(255);"
    execute "ALTER TABLE users ADD COLUMN IF NOT EXISTS timezone VARCHAR(255) DEFAULT 'Europe/Berlin' NOT NULL;"
    execute "ALTER TABLE users ADD COLUMN IF NOT EXISTS locale VARCHAR(255) DEFAULT 'de' NOT NULL;"
    execute "ALTER TABLE users ADD COLUMN IF NOT EXISTS pending_email CITEXT;"

    execute "ALTER TABLE api_tokens ADD COLUMN IF NOT EXISTS token_prefix VARCHAR(255);"
    execute "ALTER TABLE api_tokens ADD COLUMN IF NOT EXISTS scopes VARCHAR(255) DEFAULT 'all' NOT NULL;"

    execute "ALTER TABLE user_identities ADD COLUMN IF NOT EXISTS access_token_expires_at TIMESTAMP WITH TIME ZONE;"
  end

  def down do
    execute "ALTER TABLE user_identities DROP COLUMN IF EXISTS access_token_expires_at;"
    execute "ALTER TABLE api_tokens DROP COLUMN IF EXISTS scopes;"
    execute "ALTER TABLE api_tokens DROP COLUMN IF EXISTS token_prefix;"
    execute "ALTER TABLE users DROP COLUMN IF EXISTS pending_email;"
    execute "ALTER TABLE users DROP COLUMN IF EXISTS locale;"
    execute "ALTER TABLE users DROP COLUMN IF EXISTS timezone;"
    execute "ALTER TABLE users DROP COLUMN IF EXISTS phone;"
    execute "ALTER TABLE users DROP COLUMN IF EXISTS last_name;"
    execute "ALTER TABLE users DROP COLUMN IF EXISTS first_name;"
    execute "ALTER TABLE users DROP COLUMN IF EXISTS display_name;"
  end
end
