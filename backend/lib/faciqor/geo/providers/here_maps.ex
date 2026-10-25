defmodule Faciqor.Geo.Providers.HereMaps do
  @moduledoc """
  HERE Maps Geocoding & Search API v7 Adapter.
  Nutzt den in den Organisationseinstellungen hinterlegten `here_api_key`.
  """
  @behaviour Faciqor.Geo.Provider

  alias Faciqor.Geo.AddressCandidate

  @default_base_url "https://geocode.search.hereapi.com/v1/geocode"

  @impl true
  def search(query, opts \\ []) when is_binary(query) do
    trimmed = String.trim(query)
    api_key = Keyword.get(opts, :api_key)

    cond do
      trimmed == "" ->
        {:ok, []}

      is_nil(api_key) or String.trim(to_string(api_key)) == "" ->
        {:error, :missing_here_api_key}

      true ->
        base_url = Keyword.get(opts, :base_url, @default_base_url)
        limit = Keyword.get(opts, :limit, 5)

        params =
          URI.encode_query(%{
            "q" => trimmed,
            "apiKey" => String.trim(to_string(api_key)),
            "limit" => to_string(limit),
            "lang" => "de-DE"
          })

        url = "#{base_url}?#{params}"
        headers = [{"Accept", "application/json"}]

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
      {:ok, %{"items" => items}} when is_list(items) ->
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
    pos = Map.get(item, "position", %{}) || %{}

    lat_str = format_coord(Map.get(pos, "lat", "52.5200000"))
    lng_str = format_coord(Map.get(pos, "lng", "13.4050000"))

    street =
      addr["street"] ||
        extract_street_from_query(fallback_query)

    house_number =
      addr["houseNumber"] ||
        extract_house_number_from_query(fallback_query)

    city = addr["city"] || "Berlin"
    postal_code = addr["postalCode"] || "10115"
    country_code = map_country_code(addr["countryCode"] || "DEU")

    if street != "" and house_number != "" do
      %AddressCandidate{
        provider_place_id: Map.get(item, "id") || "here:#{street}-#{house_number}",
        formatted_label: Map.get(item, "title") || addr["label"] || "#{street} #{house_number}, #{postal_code} #{city}",
        street: street,
        house_number: house_number,
        postal_code: postal_code,
        city: city,
        country_code: country_code,
        latitude: Decimal.new(lat_str),
        longitude: Decimal.new(lng_str)
      }
    else
      nil
    end
  end

  defp format_coord(val) when is_binary(val), do: val
  defp format_coord(val) when is_integer(val), do: Integer.to_string(val)
  defp format_coord(%Decimal{} = val), do: Decimal.to_string(val, :normal)
  defp format_coord(val), do: to_string(val)

  defp map_country_code("DEU"), do: "DE"
  defp map_country_code("AUT"), do: "AT"
  defp map_country_code("CHE"), do: "CH"
  defp map_country_code("USA"), do: "US"
  defp map_country_code(code) when is_binary(code) and byte_size(code) == 2, do: String.upcase(code)
  defp map_country_code(_), do: "DE"

  defp extract_street_from_query(q) do
    {street, _num} = Faciqor.Operations.TitleBuilder.extract_street_and_number(q)
    street
  end

  defp extract_house_number_from_query(q) do
    {_street, num} = Faciqor.Operations.TitleBuilder.extract_street_and_number(q)
    num
  end
end
