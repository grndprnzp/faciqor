defmodule Faciqor.Geo do
  @moduledoc """
  Zentrale, provider-agnostische Fassade für Geocoding, Adresssuche und Karten-Tile-Konfiguration.
  Der funktionale Kern (`Faciqor.Operations`) und die Präsentationsschicht (`FaciqorWeb`)
  nutzen ausschließlich dieses Modul, ohne Details der konkreten Provider zu kennen.
  """

  alias Faciqor.Accounts.Organization
  alias Faciqor.Geo.Providers.{HereMaps, Mock, Nominatim}

  @doc """
  Führt eine Adresssuche über den in der Organisation konfigurierten Geocoding-Provider durch.
  """
  def search_address(%Organization{} = org, query, opts \\ []) when is_binary(query) do
    provider_type = org.geocoding_provider || :nominatim
    api_key = org.here_api_key

    adapter = resolve_adapter(provider_type, opts)
    call_opts = Keyword.merge(opts, provider_type: provider_type, api_key: api_key)

    case adapter.search(query, call_opts) do
      {:ok, candidates} ->
        {:ok, candidates}

      {:error, {:network_error, _}} ->
        # Fallback auf deterministischen lokalen Resolver, falls in einer isolierten Umgebung kein Internet besteht
        if Keyword.get(opts, :allow_offline_fallback, true) do
          Mock.search(query, call_opts)
        else
          {:error, :geocoding_unreachable}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Liefert die abstrahierte Karten-Tile-Konfiguration für das Frontend (Leaflet)
  anhand des in der Organisation hinterlegten `map_provider`.
  """
  def map_tile_config(%Organization{} = org) do
    case {org.map_provider || :openstreetmap, org.here_api_key} do
      {:here, api_key} when is_binary(api_key) and api_key != "" ->
        %{
          provider: "here",
          tile_url:
            "https://maps.hereapi.com/v3/base/mc/{z}/{x}/{y}/png8?style=lite.day&apiKey=#{URI.encode_www_form(String.trim(api_key))}",
          attribution: "&copy; HERE Maps"
        }

      _ ->
        %{
          provider: "openstreetmap",
          tile_url: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          attribution: "&copy; <a href=\"https://www.openstreetmap.org/copyright\">OpenStreetMap</a> Mitwirkende"
        }
    end
  end

  defp resolve_adapter(provider_type, opts) do
    case Keyword.get(opts, :adapter) || Application.get_env(:faciqor, :geo_provider_adapter) do
      nil ->
        case provider_type do
          :here -> HereMaps
          _ -> Nominatim
        end

      custom_adapter ->
        custom_adapter
    end
  end
end
