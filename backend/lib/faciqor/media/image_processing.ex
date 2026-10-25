defmodule Faciqor.Media.ImageProcessing do
  @moduledoc """
  Zentraler Dienst zur Bildvalidierung und Bildmanipulation für die gesamte Faciqor-Anwendung.
  Basiert auf dem 'image'-Paket (libvips / vix) für hohe Verarbeitungsgeschwindigkeit auf Dirty Schedulers.
  """

  @max_file_size 5 * 1024 * 1024
  @min_dimension 512

  @doc """
  Validiert ein Bild (entweder als Pfad oder als Binärdaten):
  - Maximale Dateigröße (Standard: 5MB)
  - Quadratisches Seitenverhältnis 1:1 (Breite == Höhe)
  - Mindestabmessung der kürzesten Seite (Standard: 512px)
  """
  def validate_avatar_or_logo(binary_or_path, opts \\ []) do
    max_size = Keyword.get(opts, :max_size, @max_file_size)
    min_dim = Keyword.get(opts, :min_dimension, @min_dimension)

    byte_size =
      case binary_or_path do
        path when is_binary(path) and byte_size(path) < 4096 and not is_nil(path) ->
          if File.exists?(path), do: File.stat!(path).size, else: byte_size(binary_or_path)

        binary when is_binary(binary) ->
          byte_size(binary)
      end

    if byte_size > max_size do
      {:error, :file_too_large}
    else
      case Image.open(binary_or_path) do
        {:ok, img} ->
          width = Image.width(img)
          height = Image.height(img)

          cond do
            width != height ->
              {:error, {:not_square, width, height}}

            width < min_dim or height < min_dim ->
              {:error, {:dimensions_too_small, width, height, min_dim}}

            true ->
              {:ok, %{width: width, height: height, byte_size: byte_size}}
          end

        {:error, reason} ->
          {:error, {:invalid_image, reason}}
      end
    end
  end

  @doc """
  Erzeugt quadratische WebP-Bildvarianten für die übergebenen Zielgrößen (Standard: [64, 128, 256, 512]).
  
  Optionen:
  - `:strip_exif` (Standard: true): Entfernt sensible EXIF-/Metadaten für öffentliche Buckets.
    Wichtig: Für Beweisaufnahmen (faciqor-vault) auf `false` setzen.
  - `:quality` (Standard: 85): WebP-Kompressionsqualität.
  """
  def generate_variants(binary_or_path, sizes \\ [64, 128, 256, 512], opts \\ []) do
    strip_exif? = Keyword.get(opts, :strip_exif, true)
    quality = Keyword.get(opts, :quality, 85)

    case Image.open(binary_or_path) do
      {:ok, img} ->
        variants =
          Enum.reduce_while(sizes, {:ok, %{}}, fn size, {:ok, acc} ->
            case Image.thumbnail(img, size, height: size, crop: :center) do
              {:ok, thumb} ->
                write_opts = [
                  suffix: ".webp",
                  quality: quality,
                  strip_metadata: strip_exif?
                ]

                case Image.write(thumb, :memory, write_opts) do
                  {:ok, webp_binary} ->
                    {:cont, {:ok, Map.put(acc, size, webp_binary)}}

                  {:error, reason} ->
                    {:halt, {:error, {:write_failed, size, reason}}}
                end

              {:error, reason} ->
                {:halt, {:error, {:thumbnail_failed, size, reason}}}
            end
          end)

        variants

      {:error, reason} ->
        {:error, {:open_failed, reason}}
    end
  end
end
