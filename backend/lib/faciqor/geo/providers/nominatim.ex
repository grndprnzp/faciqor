defmodule Faciqor.Geo.Providers.Nominatim do
  @moduledoc """
  OpenStreetMap Nominatim Geocoding-Provider (Standard-Provider).
  """
  @behaviour Faciqor.Geo.Provider

  alias Faciqor.Geo.AddressCandidate

  @default_base_url "https://nominatim.openstreetmap.org/search"

  @impl true
  def search(query, opts \\ []) when is_binary(query) do
    trimmed = String.trim(query)

    if trimmed == "" do
      {:ok, []}
    else
      base_url = Keyword.get(opts, :base_url, @default_base_url)
      limit = Keyword.get(opts, :limit, 5)

      params =
        URI.encode_query(%{
          "q" => trimmed,
          "format" => "jsonv2",
          "addressdetails" => "1",
          "limit" => to_string(limit)
        })

      url = "#{base_url}?#{params}"
      headers = [{"User-Agent", "Faciqor-ERP/1.0"}, {"Accept-Language", "de,en"}]

      case :hackney.request(:get, url, headers, "", [:with_body, recv_timeout: 5_000, connect_timeout: 3_000]) do
        {:ok, 200, _resp_headers, body} ->
          parse_response(body, trimmed)

        {:ok, status, _resp_headers, _body} ->
          {:error, {:http_error, status}}

        {:error, reason} ->
          {:error, {:network_error, reason}}
      end
    end
  end

  def parse_response(body, fallback_query) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, items} when is_list(items) ->
        candidates =
          items
          |> Enum.map(&item_to_candidate(&1, fallback_query))
          |> Enum.reject(&is_nil/1)

        {:ok, candidates}

      _ ->
        {:error, :invalid_json}
    end
  end

  defp item_to_candidate(item, fallback_query) when is_map(item) do
    addr = Map.get(item, "address", %{}) || %{}
    lat_str = to_string(Map.get(item, "lat", "52.5200000"))
    lon_str = to_string(Map.get(item, "lon", "13.4050000"))

    street =
      addr["road"] ||
        addr["pedestrian"] ||
        addr["footway"] ||
        addr["street"] ||
        extract_street_from_query(fallback_query)

    house_number =
      addr["house_number"] ||
        extract_house_number_from_query(fallback_query)

    city =
      addr["city"] ||
        addr["town"] ||
        addr["village"] ||
        addr["municipality"] ||
        "Berlin"

    postal_code = addr["postcode"] || "10115"
    country_code = String.upcase(addr["country_code"] || "DE")

    if street != "" and house_number != "" do
      %AddressCandidate{
        provider_place_id: "osm:#{Map.get(item, "place_id", "")}",
        formatted_label: Map.get(item, "display_name") || "#{street} #{house_number}, #{postal_code} #{city}",
        street: street,
        house_number: house_number,
        postal_code: postal_code,
        city: city,
        country_code: country_code,
        latitude: Decimal.new(lat_str),
        longitude: Decimal.new(lon_str)
      }
    else
      nil
    end
  end

  defp extract_street_from_query(q) do
    {street, _num} = Faciqor.Operations.TitleBuilder.extract_street_and_number(q)
    street
  end

  defp extract_house_number_from_query(q) do
    {_street, num} = Faciqor.Operations.TitleBuilder.extract_street_and_number(q)
    num
  end
end
