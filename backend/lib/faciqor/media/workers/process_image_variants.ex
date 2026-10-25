defmodule Faciqor.Media.Workers.ProcessImageVariants do
  @moduledoc """
  Asynchroner Oban-Worker zur Erstellung der Bildvarianten (64x64, 128x128, 256x256, 512x512).
  Lädt das Quellbild aus dem S3-Storage (SeaweedFS / S3), erzeugt WebP-Varianten mit optionalem
  EXIF-Strip (aktiv für Public Buckets) und lädt die Varianten wieder hoch.
  """
  use Oban.Worker, queue: :default, max_attempts: 3
  require Logger
  alias Faciqor.Media
  alias Faciqor.Media.ImageProcessing
  alias Faciqor.Media.Storage

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"blob_id" => blob_id}}) do
    case Media.get_storage_blob(blob_id, authorize?: false) do
      {:ok, blob} ->
        process_blob(blob)

      {:error, reason} ->
        Logger.error("Failed to load StorageBlob #{blob_id}: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def process_blob(blob) do
    Logger.info("Processing variants for StorageBlob #{blob.id} (#{blob.key})")
    Media.update_blob_status(blob, %{status: :processing}, authorize?: false)

    case Storage.get_object(blob.bucket, blob.key) do
      {:ok, binary} ->
        case Image.open(binary) do
          {:ok, img} ->
            width = Image.width(img)
            height = Image.height(img)
            strip_exif = blob.context in [:avatar, :organization_logo, :public_asset]

            case ImageProcessing.generate_variants(binary, [64, 128, 256, 512], strip_exif: strip_exif) do
              {:ok, variants} ->
                uploaded_variants =
                  Enum.reduce(variants, %{}, fn {size, variant_binary}, acc ->
                    variant_key = "#{Path.rootname(blob.key)}_#{size}.webp"

                    case Storage.put_object(blob.bucket, variant_key, variant_binary, "image/webp") do
                      {:ok, _} ->
                        Map.put(acc, to_string(size), variant_key)

                      error ->
                        Logger.error("Failed to upload variant #{size} for blob #{blob.id}: #{inspect(error)}")
                        acc
                    end
                  end)

                Media.complete_variants(
                  blob,
                  %{
                    variants: uploaded_variants,
                    width: width,
                    height: height
                  },
                  authorize?: false
                )

                Logger.info("Successfully generated variants for StorageBlob #{blob.id}")
                :ok

              {:error, reason} ->
                Logger.error("Failed to generate variants for blob #{blob.id}: #{inspect(reason)}")
                Media.mark_blob_failed(blob, authorize?: false)
                {:error, reason}
            end

          {:error, reason} ->
            Logger.error("Failed to open image for blob #{blob.id}: #{inspect(reason)}")
            Media.mark_blob_failed(blob, authorize?: false)
            {:error, reason}
        end

      {:error, reason} ->
        Logger.error("Failed to fetch image from S3 for blob #{blob.id}: #{inspect(reason)}")
        Media.mark_blob_failed(blob, authorize?: false)
        {:error, reason}
    end
  end
end
