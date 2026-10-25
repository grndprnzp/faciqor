defmodule Faciqor.Geo.Geofence do
  @moduledoc """
  Berechnung, Serialisierung (WKT) und PostGIS-Validierung von Geofence-Zonen
  (`GEOGRAPHY(Polygon, 4326)`), strikt auf Basis von `Decimal` (keine Floats).
  """

  @lat_deg_per_meter Decimal.new("0.0000090")
  @lon_deg_per_meter Decimal.new("0.0000148")
  @diag_factor Decimal.new("0.7071068")

  @doc """
  Erzeugt ein umschließendes 8-Eck-Puffer-Polygon um alle übergebenen Teiladressen
  mit dem angegebenen Radius in Metern (Standard: 50m).
  """
  def default_polygon(addresses, radius_meters \\ 50)

  def default_polygon([], radius_meters) do
    default_polygon([%{latitude: Decimal.new("52.5200000"), longitude: Decimal.new("13.4050000")}], radius_meters)
  end

  def default_polygon(addresses, radius_meters) when is_list(addresses) do
    radius = max(10, radius_meters || 50)
    radius_dec = Decimal.new(radius)

    d_lat = Decimal.mult(radius_dec, @lat_deg_per_meter)
    d_lon = Decimal.mult(radius_dec, @lon_deg_per_meter)
    d_lat_diag = Decimal.round(Decimal.mult(d_lat, @diag_factor), 7)
    d_lon_diag = Decimal.round(Decimal.mult(d_lon, @diag_factor), 7)
    d_lat = Decimal.round(d_lat, 7)
    d_lon = Decimal.round(d_lon, 7)

    lats = Enum.map(addresses, &to_decimal(Map.get(&1, :latitude) || Map.get(&1, "latitude")))
    lons = Enum.map(addresses, &to_decimal(Map.get(&1, :longitude) || Map.get(&1, "longitude")))

    min_lat = Enum.reduce(lats, fn a, b -> if Decimal.compare(a, b) == :lt, do: a, else: b end)
    max_lat = Enum.reduce(lats, fn a, b -> if Decimal.compare(a, b) == :gt, do: a, else: b end)
    min_lon = Enum.reduce(lons, fn a, b -> if Decimal.compare(a, b) == :lt, do: a, else: b end)
    max_lon = Enum.reduce(lons, fn a, b -> if Decimal.compare(a, b) == :gt, do: a, else: b end)

    mid_lat = Decimal.round(Decimal.div(Decimal.add(min_lat, max_lat), Decimal.new(2)), 7)
    mid_lon = Decimal.round(Decimal.div(Decimal.add(min_lon, max_lon), Decimal.new(2)), 7)

    # 8 Punkte im Uhrzeigersinn (N, NE, E, SE, S, SW, W, NW) um die Bounding-Box der Adressen
    vertices = [
      point_map(Decimal.add(max_lat, d_lat), mid_lon),
      point_map(Decimal.add(max_lat, d_lat_diag), Decimal.add(max_lon, d_lon_diag)),
      point_map(mid_lat, Decimal.add(max_lon, d_lon)),
      point_map(Decimal.sub(min_lat, d_lat_diag), Decimal.add(max_lon, d_lon_diag)),
      point_map(Decimal.sub(min_lat, d_lat), mid_lon),
      point_map(Decimal.sub(min_lat, d_lat_diag), Decimal.sub(min_lon, d_lon_diag)),
      point_map(mid_lat, Decimal.sub(min_lon, d_lon)),
      point_map(Decimal.add(max_lat, d_lat_diag), Decimal.sub(min_lon, d_lon_diag))
    ]

    {:ok, wkt} = polygon_to_wkt(vertices)
    %{polygon: vertices, wkt: wkt, radius_meters: radius}
  end

  @doc """
  Konvertiert eine Liste von Koordinaten-Maps (`%{"latitude" => ..., "longitude" => ...}`)
  in einen geschlossenen PostGIS WKT-String `POLYGON((lon1 lat1, ..., lon1 lat1))`.
  """
  def polygon_to_wkt(vertices) when is_list(vertices) do
    normalized =
      vertices
      |> Enum.map(fn v ->
        lat = to_decimal(Map.get(v, :latitude) || Map.get(v, "latitude"))
        lon = to_decimal(Map.get(v, :longitude) || Map.get(v, "longitude"))
        {Decimal.round(lat, 7), Decimal.round(lon, 7)}
      end)
      |> Enum.reject(fn {lat, lon} -> is_nil(lat) or is_nil(lon) end)

    if length(normalized) < 3 do
      {:error, :insufficient_polygon_vertices}
    else
      closed_ring = close_ring(normalized)

      coords_str =
        Enum.map_join(closed_ring, ", ", fn {lat, lon} ->
          "#{Decimal.to_string(lon, :normal)} #{Decimal.to_string(lat, :normal)}"
        end)

      {:ok, "POLYGON((#{coords_str}))"}
    end
  end

  def normalize_polygon_vertices(vertices) when is_list(vertices) do
    vertices
    |> Enum.map(fn v ->
      lat = to_decimal(Map.get(v, :latitude) || Map.get(v, "latitude"))
      lon = to_decimal(Map.get(v, :longitude) || Map.get(v, "longitude"))

      if lat && lon do
        point_map(lat, lon)
      else
        nil
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  @doc """
  Prüft mittels PostGIS (`ST_IsValid` & `ST_Covers`), ob das Geofence-Polygon valide ist
  und alle erfassten Teiladressen des Objekts einschließt.
  """
  def validate_covers_addresses(wkt, addresses) when is_binary(wkt) and is_list(addresses) do
    sql = """
    SELECT
      ST_IsValid(ST_GeomFromText($1, 4326)) AS is_valid,
      bool_and(
        ST_Covers(
          ST_GeomFromText($1, 4326),
          ST_SetSRID(ST_MakePoint(lon::double precision, lat::double precision), 4326)
        )
      ) AS covers_all
    FROM unnest($2::numeric[], $3::numeric[]) AS t(lat, lon);
    """

    lats = Enum.map(addresses, &to_decimal(Map.get(&1, :latitude) || Map.get(&1, "latitude")))
    lons = Enum.map(addresses, &to_decimal(Map.get(&1, :longitude) || Map.get(&1, "longitude")))

    case Ecto.Adapters.SQL.query(Faciqor.Repo, sql, [wkt, lats, lons]) do
      {:ok, %{rows: [[true, true]]}} ->
        :ok

      {:ok, %{rows: [[false, _]]}} ->
        {:error, :invalid_polygon_geometry}

      {:ok, %{rows: [[true, false]]}} ->
        {:error, :addresses_outside_geofence}

      {:error, reason} ->
        {:error, {:postgis_error, reason}}
    end
  end

  defp close_ring([first | _] = list) do
    last = List.last(list)

    if Decimal.equal?(elem(first, 0), elem(last, 0)) and Decimal.equal?(elem(first, 1), elem(last, 1)) do
      list
    else
      list ++ [first]
    end
  end

  defp point_map(%Decimal{} = lat, %Decimal{} = lon) do
    %{
      "latitude" => Decimal.to_string(Decimal.round(lat, 7), :normal),
      "longitude" => Decimal.to_string(Decimal.round(lon, 7), :normal)
    }
  end

  def to_decimal(%Decimal{} = d), do: d

  def to_decimal(val) when is_binary(val) do
    case Decimal.parse(String.trim(val)) do
      {d, ""} -> d
      _ -> nil
    end
  end

  def to_decimal(val) when is_integer(val), do: Decimal.new(val)
  def to_decimal(_), do: nil
end
