defmodule Faciqor.Repo.Migrations.CreateStorageBlobsAndAddAvatarAndLogo do
  use Ecto.Migration

  def up do
    create table(:storage_blobs, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :bucket, :string, null: false
      add :key, :string, null: false
      add :sha256, :string
      add :content_type, :string, null: false
      add :byte_size, :bigint
      add :width, :integer
      add :height, :integer
      add :status, :string, default: "pending", null: false
      add :context, :string, default: "public_asset", null: false
      add :variants, :map, default: %{}, null: false
      add :user_id, references(:users, type: :uuid, on_delete: :nilify_all)
      add :organization_id, references(:organizations, type: :uuid, on_delete: :nilify_all)

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:storage_blobs, [:bucket, :key])
    create index(:storage_blobs, [:user_id])
    create index(:storage_blobs, [:organization_id])
    create index(:storage_blobs, [:status])

    alter table(:users) do
      add :avatar_blob_id, references(:storage_blobs, type: :uuid, on_delete: :nilify_all)
    end

    alter table(:organizations) do
      add :logo_blob_id, references(:storage_blobs, type: :uuid, on_delete: :nilify_all)
    end
  end

  def down do
    alter table(:organizations) do
      remove :logo_blob_id
    end

    alter table(:users) do
      remove :avatar_blob_id
    end

    drop table(:storage_blobs)
  end
end
