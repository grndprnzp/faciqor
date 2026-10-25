defmodule Faciqor.Media.Storage do
  @moduledoc """
  Adapter für den S3-kompatiblen Object Storage (SeaweedFS / AWS S3 / Cloudflare R2).
  Kapselt Pre-Signed URL-Generierung, Upload, Download und Löschung von Blobs.
  """

  @default_public_bucket "faciqor-public"
  @default_vault_bucket "faciqor-vault"
  @default_base_url "http://localhost:8333/faciqor-public"

  def public_bucket do
    Application.get_env(:faciqor, :media)[:public_bucket] || @default_public_bucket
  end

  def vault_bucket do
    Application.get_env(:faciqor, :media)[:vault_bucket] || @default_vault_bucket
  end

  def public_base_url do
    Application.get_env(:faciqor, :media)[:public_base_url] || @default_base_url
  end

  @doc """
  Stellt sicher, dass die konfigurierten S3-Buckets existieren (wichtig für SeaweedFS im Dev-Betrieb).
  """
  def ensure_buckets do
    for bucket <- [public_bucket(), vault_bucket()] do
      try do
        bucket
        |> ExAws.S3.put_bucket("")
        |> ExAws.request()
      rescue
        _ -> :ok
      catch
        _, _ -> :ok
      end
    end

    :ok
  end

  @doc """
  Generiert eine kurzlebige Pre-Signed PUT-URL für direkte Client-Uploads.
  """
  def generate_presigned_put_url(bucket, key, opts \\ []) do
    expires_in = Keyword.get(opts, :expires_in, 900)
    config = ExAws.Config.new(:s3)

    case ExAws.S3.presigned_url(config, :put, bucket, key, expires_in: expires_in) do
      {:ok, url} -> {:ok, url}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Speichert ein Binärobjekt direkt im S3-Storage.
  """
  def put_object(bucket, key, binary, content_type, opts \\ []) do
    cache_control = Keyword.get(opts, :cache_control, "public, max-age=31536000, immutable")

    s3_opts = [
      content_type: content_type,
      cache_control: cache_control
    ]

    bucket
    |> ExAws.S3.put_object(key, binary, s3_opts)
    |> ExAws.request()
  end

  @doc """
  Liest ein Objekt aus dem S3-Storage.
  """
  def get_object(bucket, key) do
    case bucket |> ExAws.S3.get_object(key) |> ExAws.request() do
      {:ok, %{body: body}} -> {:ok, body}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Löscht ein Objekt aus dem S3-Storage.
  """
  def delete_object(bucket, key) do
    try do
      case bucket |> ExAws.S3.delete_object(key) |> ExAws.request() do
        {:ok, _} -> :ok
        {:error, reason} -> {:error, reason}
      end
    rescue
      _ -> :ok
    catch
      _, _ -> :ok
    end
  end

  @doc """
  Gibt die vollständige, öffentlich lesbare URL für einen Storage-Key zurück.
  """
  def public_url(nil), do: nil

  def public_url(key) do
    base = public_base_url() |> String.trim_trailing("/")
    "#{base}/#{key}"
  end
end
