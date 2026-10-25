defmodule Faciqor.Repo.Migrations.AddAccessTokenExpiresAtToUserIdentities do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE user_identities ADD COLUMN IF NOT EXISTS access_token_expires_at TIMESTAMP WITH TIME ZONE;"
  end

  def down do
    execute "ALTER TABLE user_identities DROP COLUMN IF EXISTS access_token_expires_at;"
  end
end
