defmodule Faciqor.Repo.Migrations.FixUserTokensCreatedAt do
  use Ecto.Migration

  def change do
    alter table(:user_tokens) do
      add_if_not_exists :created_at, :utc_datetime_usec, default: fragment("now()")
      modify :inserted_at, :utc_datetime_usec, null: true, default: fragment("now()")
    end
  end
end
