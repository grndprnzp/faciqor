defmodule Faciqor.Media do
  use Ash.Domain,
    otp_app: :faciqor

  resources do
    resource Faciqor.Media.StorageBlob do
      define :create_storage_blob, action: :create_ticket
      define :get_storage_blob, action: :read, get_by: [:id]
      define :update_blob_status, action: :update_status
      define :complete_variants, action: :complete_variants
      define :mark_blob_failed, action: :mark_failed
      define :destroy_storage_blob, action: :destroy
    end
  end
end
