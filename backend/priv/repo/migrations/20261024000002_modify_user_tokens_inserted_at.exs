defmodule Faciqor.Repo.Migrations.ModifyUserTokensInsertedAt do
  use Ecto.Migration

  def change do
    alter table(:user_tokens) do
      modify :inserted_at, :utc_datetime_usec, null: true, default: fragment("now()")
    end
  end
end
