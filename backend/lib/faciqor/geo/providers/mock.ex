defmodule Faciqor.Geo.Providers.Mock do
  @moduledoc """
  Deterministischer Geocoding-Adapter für automatisierte Tests und Offline-Entwicklung.
  Unterstützt sowohl eindeutige Treffer als auch Mehrfachtreffer-Szenarien.
  """
  @behaviour Faciqor.Geo.Provider

  alias Faciqor.Geo.AddressCandidate
  alias Faciqor.Operations.TitleBuilder

  @impl true
  def search(query, opts \\ []) when is_binary(query) do
    provider_type = Keyword.get(opts, :provider_type, :nominatim)
    api_key = Keyword.get(opts, :api_key)

    if provider_type == :here and (is_nil(api_key) or String.trim(to_string(api_key)) == "") do
      {:error, :missing_here_api_key}
    else
      do_search(String.trim(query))
    end
  end

  defp do_search(""), do: {:ok, []}

  defp do_search(query) do
    down = String.downcase(query)

    cond do
      # Explizites Mehrfachtreffer-Szenario (wenn keine PLZ/Stadt angegeben ist für "Musterstraße" oder "Bahnhofstraße")
      (String.contains?(down, "musterstraße") or String.contains?(down, "bahnhofstraße")) and
          not (String.contains?(down, "berlin") or String.contains?(down, "münchen") or String.contains?(down, "hamburg")) ->
        {street, num} = TitleBuilder.extract_street_and_number(query)
        house_num = if num == "", do: "1", else: num

        {:ok,
         [
           %AddressCandidate{
             provider_place_id: "mock:berlin:#{street}:#{house_num}",
             formatted_label: "#{street} #{house_num}, 10115 Berlin",
             street: street,
             house_number: house_num,
             postal_code: "10115",
             city: "Berlin",
             country_code: "DE",
             latitude: Decimal.new("52.5320000"),
             longitude: Decimal.new("13.3840000")
           },
           %AddressCandidate{
             provider_place_id: "mock:munich:#{street}:#{house_num}",
             formatted_label: "#{street} #{house_num}, 80331 München",
             street: street,
             house_number: house_num,
             postal_code: "80331",
             city: "München",
             country_code: "DE",
             latitude: Decimal.new("48.1351253"),
             longitude: Decimal.new("11.5819805")
           }
         ]}

      String.contains?(down, "unbekannter-ort-ohne-treffer") ->
        {:ok, []}

      true ->
        {:ok, [build_deterministic_candidate(query)]}
    end
  end

  defp build_deterministic_candidate(query) do
    {street_part, postal_code, city, country_code} = split_address_parts(query)
    {street, house_number} = TitleBuilder.extract_street_and_number(street_part)

    street = if street == "", do: "Hauptstraße", else: street
    house_number = if house_number == "", do: "1", else: house_number

    # Deterministischer kleiner Offset auf Basis von Straße + Hausnummer rund um Berlin Mitte (52.5200, 13.4050)
    hash = :erlang.phash2("#{String.downcase(street)}:#{String.downcase(house_number)}", 1000)
    lat_offset = Decimal.mult(Decimal.new(rem(hash, 50)), Decimal.new("0.0000200"))
    lon_offset = Decimal.mult(Decimal.new(div(hash, 50)), Decimal.new("0.0000200"))

    base_lat = Decimal.new("52.5200000")
    base_lon = Decimal.new("13.4050000")

    %AddressCandidate{
      provider_place_id: "mock:#{String.downcase(street)}:#{house_number}:#{postal_code}",
      formatted_label: "#{street} #{house_number}, #{postal_code} #{city}",
      street: street,
      house_number: house_number,
      postal_code: postal_code,
      city: city,
      country_code: country_code,
      latitude: Decimal.add(base_lat, lat_offset),
      longitude: Decimal.add(base_lon, lon_offset)
    }
  end

  defp split_address_parts(query) do
    parts =
      query
      |> String.split(",", trim: true)
      |> Enum.map(&String.trim/1)

    case parts do
      [street_part, city_part | _] ->
        case Regex.run(~r/^(\d{4,5})\s+(.+)$/, city_part) do
          [_, zip, city] -> {street_part, zip, String.trim(city), "DE"}
          _ -> {street_part, "10115", city_part, "DE"}
        end

      [street_part] ->
        {street_part, "10115", "Berlin", "DE"}

      [] ->
        {"Hauptstraße 1", "10115", "Berlin", "DE"}
    end
  end
end
