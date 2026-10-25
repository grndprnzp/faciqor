defmodule Faciqor.Media.StorageBlob do
  use Ash.Resource,
    otp_app: :faciqor,
    domain: Faciqor.Media,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "storage_blobs"
    repo Faciqor.Repo
  end

  policies do
    policy action_type(:create) do
      authorize_if actor_present()
    end

    policy action_type(:read) do
      authorize_if always()
    end

    policy action_type(:update) do
      authorize_if always()
    end

    policy action_type(:destroy) do
      authorize_if actor_present()
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :bucket, :string do
      allow_nil? false
      public? true
    end

    attribute :key, :string do
      allow_nil? false
      public? true
    end

    attribute :sha256, :string do
      allow_nil? true
      public? true
    end

    attribute :content_type, :string do
      allow_nil? false
      public? true
    end

    attribute :byte_size, :integer do
      allow_nil? true
      public? true
    end

    attribute :width, :integer do
      allow_nil? true
      public? true
    end

    attribute :height, :integer do
      allow_nil? true
      public? true
    end

    attribute :status, :atom do
      allow_nil? false
      default :pending
      public? true
      constraints one_of: [:pending, :processing, :ready, :failed]
    end

    attribute :context, :atom do
      allow_nil? false
      default :public_asset
      public? true
      constraints one_of: [:avatar, :organization_logo, :public_asset, :vault_proof]
    end

    attribute :variants, :map do
      allow_nil? false
      default %{}
      public? true
    end

    attribute :user_id, :uuid do
      allow_nil? true
      public? true
    end

    attribute :organization_id, :uuid do
      allow_nil? true
      public? true
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :user, Faciqor.Accounts.User do
      allow_nil? true
      attribute_writable? true
    end

    belongs_to :organization, Faciqor.Accounts.Organization do
      allow_nil? true
      attribute_writable? true
    end
  end

  actions do
    defaults [:read, :destroy]

    create :create_ticket do
      accept [
        :bucket,
        :key,
        :sha256,
        :content_type,
        :byte_size,
        :width,
        :height,
        :context,
        :user_id,
        :organization_id
      ]

      change set_attribute(:status, :pending)
    end

    update :update_status do
      accept [:status]
    end

    update :complete_variants do
      accept [:variants, :status, :width, :height]
      change set_attribute(:status, :ready)
    end

    update :mark_failed do
      change set_attribute(:status, :failed)
    end
  end

  identities do
    identity :unique_bucket_key, [:bucket, :key]
  end

  @doc """
  Löscht ein StorageBlob-Objekt samt Originaldatei und aller generierten Varianten aus S3 und der Datenbank.
  """
  def cleanup_blob(blob_id) when is_binary(blob_id) do
    case Faciqor.Media.get_storage_blob(blob_id, authorize?: false) do
      {:ok, blob} ->
        Faciqor.Media.Storage.delete_object(blob.bucket, blob.key)

        if is_map(blob.variants) do
          Enum.each(blob.variants, fn {_size, variant_key} ->
            Faciqor.Media.Storage.delete_object(blob.bucket, variant_key)
          end)
        end

        Faciqor.Media.destroy_storage_blob(blob, authorize?: false)

      _ ->
        :ok
    end
  end

  def cleanup_blob(_), do: :ok
end
