defmodule Faciqor.Operations do
  @moduledoc """
  Ash-Domain für Liegenschaften, Objekte (`Facility`), Teiladressen (`FacilityAddress`)
  und mandantenspezifische Nummernkreise (`NumberRange`) gemäß REQ-M2-FACILITIES.
  """
  use Ash.Domain,
    otp_app: :faciqor

  require Ash.Query

  alias Faciqor.Accounts
  alias Faciqor.Geo
  alias Faciqor.Geo.Geofence
  alias Faciqor.Operations.{Facility, FacilityAddress, NumberRange, TitleBuilder}
  alias Faciqor.Repo

  resources do
    resource Faciqor.Operations.NumberRange
    resource Faciqor.Operations.Facility
    resource Faciqor.Operations.FacilityAddress
  end

  # --- Number Ranges ---

  @doc """
  Stellt sicher, dass für die übergebene `tenant_id` ein Standard-Nummernkreis existiert.
  """
  def ensure_default_number_range(tenant_id, entity_type \\ :facility) when is_binary(tenant_id) do
    sql = """
    INSERT INTO number_ranges (id, tenant_id, entity_type, prefix, start_value, current_value, step, suffix, inserted_at, updated_at)
    VALUES (uuid_generate_v4(), $1::uuid, $2, 'OBJ-', 1000, NULL, 1, '', NOW(), NOW())
    ON CONFLICT (tenant_id, entity_type) DO NOTHING;
    """

    Ecto.Adapters.SQL.query!(Repo, sql, [Ecto.UUID.dump!(tenant_id), to_string(entity_type)])
    :ok
  end

  @doc """
  Liest den Nummernkreis einer Organisation (und legt den Default an, falls noch nicht vorhanden).
  Erfordert `actor:` und `tenant:`.
  """
  def get_number_range(entity_type \\ :facility, opts) do
    actor = Keyword.fetch!(opts, :actor)
    tenant_id = Keyword.fetch!(opts, :tenant)

    ensure_default_number_range(tenant_id, entity_type)

    NumberRange
    |> Ash.Query.filter(entity_type == ^entity_type)
    |> Ash.read_one(actor: actor, tenant: tenant_id)
    |> case do
      {:ok, %NumberRange{} = nr} -> {:ok, nr}
      {:ok, nil} -> {:error, Ash.Error.Query.NotFound.exception(primary_key: %{entity_type: entity_type})}
      {:error, err} -> {:error, err}
    end
  end

  @doc """
  Aktualisiert den Nummernkreis einer Organisation (nur für `:owner`).
  Erfordert `actor:` und `tenant:`.
  """
  def update_number_range(attrs, opts) when is_map(attrs) do
    actor = Keyword.fetch!(opts, :actor)
    tenant_id = Keyword.fetch!(opts, :tenant)
    entity_type = Map.get(attrs, :entity_type) || Map.get(attrs, "entity_type") || :facility
    clean_attrs = Map.drop(attrs, [:entity_type, "entity_type"])

    with {:ok, nr} <- get_number_range(entity_type, actor: actor, tenant: tenant_id) do
      Repo.transaction(fn ->
        set_local_tenant!(tenant_id)

        case nr
             |> Ash.Changeset.for_update(:update_number_range, clean_attrs, actor: actor, tenant: tenant_id)
             |> Ash.update(actor: actor, tenant: tenant_id) do
          {:ok, updated} -> updated
          {:error, err} -> Repo.rollback(err)
        end
      end)
    end
  end

  @doc """
  Vergibt atomar den nächsten `business_key` innerhalb einer laufenden Datenbank-Transaktion.
  """
  def allocate_next_business_key!(tenant_id, entity_type \\ :facility, %Date{} = date \\ Date.utc_today()) do
    ensure_default_number_range(tenant_id, entity_type)

    sql = """
    UPDATE number_ranges
    SET current_value = CASE
      WHEN current_value IS NULL THEN start_value
      ELSE GREATEST(current_value + step, start_value)
    END,
    updated_at = NOW()
    WHERE tenant_id = $1::uuid AND entity_type = $2
    RETURNING prefix, current_value, suffix;
    """

    %{rows: [[prefix, allocated_val, suffix]]} =
      Ecto.Adapters.SQL.query!(Repo, sql, [Ecto.UUID.dump!(tenant_id), to_string(entity_type)])

    NumberRange.format_key(prefix, allocated_val, suffix, date)
  end

  # --- Facilities ---

  @doc """
  Listet alle Objekte einer Organisation auf.
  Erfordert `actor:` und `tenant:`.
  """
  def list_facilities(opts) do
    actor = Keyword.fetch!(opts, :actor)
    tenant_id = Keyword.fetch!(opts, :tenant)
    include_archived? = Keyword.get(opts, :include_archived?, false)
    search = Keyword.get(opts, :search)

    query =
      Facility
      |> Ash.Query.load(:addresses)
      |> Ash.Query.sort(inserted_at: :desc)

    query =
      if include_archived? do
        query
      else
        Ash.Query.filter(query, is_nil(archived_at))
      end

    case Ash.read(query, actor: actor, tenant: tenant_id) do
      {:ok, facilities} ->
        filtered =
          if is_binary(search) and String.trim(search) != "" do
            term = String.downcase(String.trim(search))

            Enum.filter(facilities, fn f ->
              String.contains?(String.downcase(to_string(f.business_key)), term) or
                String.contains?(String.downcase(f.title || ""), term) or
                Enum.any?(f.addresses || [], fn a ->
                  String.contains?(String.downcase("#{a.street} #{a.house_number} #{a.postal_code} #{a.city}"), term)
                end)
            end)
          else
            facilities
          end

        {:ok, filtered}

      {:error, err} ->
        {:error, err}
    end
  end

  @doc """
  Lädt ein einzelnes Objekt anhand seiner UUID oder seines `business_key`.
  Erfordert `actor:` und `tenant:`.
  """
  def get_facility_by_id_or_key(id_or_key, opts) when is_binary(id_or_key) do
    actor = Keyword.fetch!(opts, :actor)
    tenant_id = Keyword.fetch!(opts, :tenant)
    trimmed = String.trim(id_or_key)

    query =
      case Ecto.UUID.cast(trimmed) do
        {:ok, uuid} ->
          Facility |> Ash.Query.filter(id == ^uuid or business_key == ^trimmed)

        :error ->
          Facility |> Ash.Query.filter(business_key == ^trimmed)
      end

    query
    |> Ash.Query.load(:addresses)
    |> Ash.read_one(actor: actor, tenant: tenant_id)
    |> case do
      {:ok, %Facility{} = facility} ->
        {:ok, facility}

      {:ok, nil} ->
        {:error, Ash.Error.Query.NotFound.exception(primary_key: %{id_or_business_key: trimmed})}

      {:error, err} ->
        {:error, err}
    end
  end

  @doc """
  Legt ein neues Objekt (`Facility`) samt aller Teiladressen (`FacilityAddress`),
  automatisch generiertem `business_key`, deterministischem `title` und PostGIS-validierter
  `geofence_zone` an.
  Erfordert `actor:` und `tenant:`.
  """
  def create_facility(params, opts) when is_map(params) do
    actor = Keyword.fetch!(opts, :actor)
    tenant_id = Keyword.fetch!(opts, :tenant)

    raw_addresses = Map.get(params, :addresses) || Map.get(params, "addresses") || []
    raw_polygon = Map.get(params, :geofence_polygon) || Map.get(params, "geofence_polygon") || []
    radius_meters = Map.get(params, :geofence_radius_meters) || Map.get(params, "geofence_radius_meters") || 50

    with {:ok, org} <- load_tenant_org(tenant_id, actor),
         {:ok, normalized_addresses} <- prepare_and_geocode_addresses(raw_addresses, org),
         {:ok, %{polygon: polygon, wkt: wkt, radius_meters: eff_radius}} <-
           prepare_geofence(normalized_addresses, raw_polygon, radius_meters),
         :ok <- validate_geofence_coverage(wkt, normalized_addresses) do
      title = TitleBuilder.build_title(normalized_addresses)

      Repo.transaction(fn ->
        set_local_tenant!(tenant_id)

        business_key = allocate_next_business_key!(tenant_id, :facility)

        facility =
          Facility
          |> Ash.Changeset.for_create(
            :create_facility_record,
            %{
              business_key: business_key,
              title: title,
              geofence_wkt: wkt,
              geofence_polygon: polygon,
              geofence_radius_meters: eff_radius
            },
            actor: actor,
            tenant: tenant_id
          )
          |> Ash.create(actor: actor, tenant: tenant_id)
          |> case do
            {:ok, f} -> f
            {:error, err} -> Repo.rollback(err)
          end

        insert_facility_addresses!(facility.id, normalized_addresses, actor, tenant_id)

        loaded = Ash.load!(facility, :addresses, actor: actor, tenant: tenant_id)
        broadcast_tenant_event(tenant_id, {:facility_created, loaded.id})
        loaded
      end)
    end
  end

  @doc """
  Aktualisiert die Teiladressen und/oder die Geofence-Zone eines bestehenden Objekts.
  Der `title` wird automatisch neu berechnet; der `business_key` bleibt unverändert.
  Erfordert `actor:` und `tenant:`.
  """
  def update_facility(%Facility{} = facility, params, opts) when is_map(params) do
    actor = Keyword.fetch!(opts, :actor)
    tenant_id = Keyword.fetch!(opts, :tenant)

    facility = Ash.load!(facility, :addresses, actor: actor, tenant: tenant_id)

    raw_addresses =
      case Map.get(params, :addresses) || Map.get(params, "addresses") do
        list when is_list(list) and list != [] -> list
        _ -> Enum.map(facility.addresses, &address_struct_to_map/1)
      end

    raw_polygon = Map.get(params, :geofence_polygon) || Map.get(params, "geofence_polygon") || []

    radius_meters =
      Map.get(params, :geofence_radius_meters) ||
        Map.get(params, "geofence_radius_meters") ||
        facility.geofence_radius_meters || 50

    with {:ok, org} <- load_tenant_org(tenant_id, actor),
         {:ok, normalized_addresses} <- prepare_and_geocode_addresses(raw_addresses, org),
         {:ok, %{polygon: polygon, wkt: wkt, radius_meters: eff_radius}} <-
           prepare_geofence(normalized_addresses, raw_polygon, radius_meters),
         :ok <- validate_geofence_coverage(wkt, normalized_addresses) do
      title = TitleBuilder.build_title(normalized_addresses)

      Repo.transaction(fn ->
        set_local_tenant!(tenant_id)

        updated_facility =
          facility
          |> Ash.Changeset.for_update(
            :update_facility_record,
            %{
              title: title,
              geofence_wkt: wkt,
              geofence_polygon: polygon,
              geofence_radius_meters: eff_radius
            },
            actor: actor,
            tenant: tenant_id
          )
          |> Ash.update(actor: actor, tenant: tenant_id)
          |> case do
            {:ok, f} -> f
            {:error, err} -> Repo.rollback(err)
          end

        # Bestehende Teiladressen ersetzen
        Enum.each(facility.addresses || [], fn addr ->
          case Ash.destroy(addr, actor: actor, tenant: tenant_id) do
            :ok -> :ok
            {:error, err} -> Repo.rollback(err)
          end
        end)

        insert_facility_addresses!(updated_facility.id, normalized_addresses, actor, tenant_id)

        loaded = Ash.load!(updated_facility, :addresses, actor: actor, tenant: tenant_id)
        broadcast_tenant_event(tenant_id, {:facility_updated, loaded.id})
        loaded
      end)
    end
  end

  @doc """
  Archiviert ein Objekt (`archived_at` setzen).
  """
  def archive_facility(%Facility{} = facility, opts) do
    actor = Keyword.fetch!(opts, :actor)
    tenant_id = Keyword.fetch!(opts, :tenant)

    Repo.transaction(fn ->
      set_local_tenant!(tenant_id)

      facility
      |> Ash.Changeset.for_update(:archive_facility, %{}, actor: actor, tenant: tenant_id)
      |> Ash.update(actor: actor, tenant: tenant_id)
      |> case do
        {:ok, updated} ->
          loaded = Ash.load!(updated, :addresses, actor: actor, tenant: tenant_id)
          broadcast_tenant_event(tenant_id, {:facility_archived, loaded.id})
          loaded

        {:error, err} ->
          Repo.rollback(err)
      end
    end)
  end

  @doc """
  Reaktiviert ein archiviertes Objekt (`archived_at = nil`).
  """
  def unarchive_facility(%Facility{} = facility, opts) do
    actor = Keyword.fetch!(opts, :actor)
    tenant_id = Keyword.fetch!(opts, :tenant)

    Repo.transaction(fn ->
      set_local_tenant!(tenant_id)

      facility
      |> Ash.Changeset.for_update(:unarchive_facility, %{}, actor: actor, tenant: tenant_id)
      |> Ash.update(actor: actor, tenant: tenant_id)
      |> case do
        {:ok, updated} ->
          loaded = Ash.load!(updated, :addresses, actor: actor, tenant: tenant_id)
          broadcast_tenant_event(tenant_id, {:facility_unarchived, loaded.id})
          loaded

        {:error, err} ->
          Repo.rollback(err)
      end
    end)
  end

  @doc """
  Löscht ein Objekt vollständig (nur durch `:owner` erlaubt, sofern keine Buchungen/Aufträge verknüpft sind).
  """
  def delete_facility(%Facility{} = facility, opts) do
    actor = Keyword.fetch!(opts, :actor)
    tenant_id = Keyword.fetch!(opts, :tenant)

    Repo.transaction(fn ->
      set_local_tenant!(tenant_id)

      case Ash.destroy(facility, actor: actor, tenant: tenant_id) do
        :ok ->
          broadcast_tenant_event(tenant_id, {:facility_deleted, facility.id})
          :ok

        {:error, err} ->
          Repo.rollback(err)
      end
    end)
  end

  # --- Private Helpers ---

  defp set_local_tenant!(tenant_id) when is_binary(tenant_id) do
    Ecto.Adapters.SQL.query!(Repo, "SET LOCAL app.current_tenant_id = '#{tenant_id}'", [])
  end

  defp load_tenant_org(tenant_id, actor) do
    Accounts.get_organization_by_id_or_handle(tenant_id, actor: actor)
  end

  defp prepare_and_geocode_addresses([], _org) do
    {:error,
     Ash.Error.Invalid.exception(
       errors: [
         Ash.Error.Changes.InvalidAttribute.exception(
           field: :addresses,
           message: "Mindestens eine gültige Adresse muss angegeben werden."
         )
       ]
     )}
  end

  defp prepare_and_geocode_addresses(raw_addresses, org) when is_list(raw_addresses) do
    raw_addresses
    |> Enum.with_index()
    |> Enum.reduce_while({:ok, []}, fn {raw, idx}, {:ok, acc} ->
      case resolve_single_address(raw, idx, org) do
        {:ok, resolved} -> {:cont, {:ok, acc ++ [resolved]}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
    |> case do
      {:ok, list} ->
        # Sicherstellen, dass genau eine Adresse als `is_primary` markiert ist
        has_primary? = Enum.any?(list, & &1.is_primary)

        normalized =
          if has_primary? do
            list
          else
            List.update_at(list, 0, &Map.put(&1, :is_primary, true))
          end

        {:ok, normalized}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp resolve_single_address(raw, idx, org) when is_map(raw) do
    street = to_string(Map.get(raw, :street) || Map.get(raw, "street") || "") |> String.trim()
    house_number = to_string(Map.get(raw, :house_number) || Map.get(raw, "house_number") || "") |> String.trim()
    postal_code = to_string(Map.get(raw, :postal_code) || Map.get(raw, "postal_code") || "") |> String.trim()
    city = to_string(Map.get(raw, :city) || Map.get(raw, "city") || "") |> String.trim()
    country_code = to_string(Map.get(raw, :country_code) || Map.get(raw, "country_code") || "DE") |> String.trim()
    is_primary = Map.get(raw, :is_primary) || Map.get(raw, "is_primary") || false
    place_id = Map.get(raw, :provider_place_id) || Map.get(raw, "provider_place_id")

    lat_dec = Geofence.to_decimal(Map.get(raw, :latitude) || Map.get(raw, "latitude"))
    lon_dec = Geofence.to_decimal(Map.get(raw, :longitude) || Map.get(raw, "longitude"))

    cond do
      street == "" or house_number == "" ->
        {:error,
         Ash.Error.Invalid.exception(
           errors: [
             Ash.Error.Changes.InvalidAttribute.exception(
               field: :addresses,
               message: "Straße und Hausnummer dürfen nicht leer sein."
             )
           ]
         )}

      not is_nil(lat_dec) and not is_nil(lon_dec) ->
        {clean_street, clean_num} = normalize_street_and_number(street, house_number)
        {num_int, suffix, canonical_num} = TitleBuilder.parse_house_number(clean_num)

        {:ok,
         %{
           street: clean_street,
           house_number: canonical_num,
           house_number_numeric: num_int,
           house_number_suffix: suffix,
           postal_code: if(postal_code == "", do: "10115", else: postal_code),
           city: if(city == "", do: "Berlin", else: city),
           country_code: if(country_code == "", do: "DE", else: country_code),
           latitude: lat_dec,
           longitude: lon_dec,
           is_primary: is_primary == true,
           sort_order: idx,
           provider_place_id: place_id
         }}

      true ->
        query =
          [
            "#{street} #{house_number}",
            String.trim("#{postal_code} #{city}")
          ]
          |> Enum.reject(&(&1 == ""))
          |> Enum.join(", ")

        case Geo.search_address(org, query) do
          {:ok, [single]} ->
            {clean_street, clean_num} = normalize_street_and_number(street, house_number)
            {num_int, suffix, canonical_num} = TitleBuilder.parse_house_number(clean_num)

            {:ok,
             %{
               street: clean_street,
               house_number: canonical_num,
               house_number_numeric: num_int,
               house_number_suffix: suffix,
               postal_code: if(postal_code != "", do: postal_code, else: single.postal_code),
               city: if(city != "", do: city, else: single.city),
               country_code: if(country_code != "", do: country_code, else: single.country_code),
               latitude: single.latitude,
               longitude: single.longitude,
               is_primary: is_primary == true,
               sort_order: idx,
               provider_place_id: single.provider_place_id
             }}

          {:ok, [_ | _] = multiple} ->
            labels = Enum.map_join(multiple, " | ", & &1.formatted_label)

            {:error,
             Ash.Error.Invalid.exception(
               errors: [
                 Ash.Error.Changes.InvalidAttribute.exception(
                   field: :addresses,
                   message: "Mehrfachtreffer für '#{query}': Bitte präzisieren (#{labels})"
                 )
               ]
             )}

          {:ok, []} ->
            {:error,
             Ash.Error.Invalid.exception(
               errors: [
                 Ash.Error.Changes.InvalidAttribute.exception(
                   field: :addresses,
                   message: "Keine Geokoordinaten für '#{query}' gefunden."
                 )
               ]
             )}

          {:error, reason} ->
            {:error,
             Ash.Error.Invalid.exception(
               errors: [
                 Ash.Error.Changes.InvalidAttribute.exception(
                   field: :addresses,
                   message: "Geocoding-Fehler: #{inspect(reason)}"
                 )
               ]
             )}
        end
    end
  end

  defp normalize_street_and_number(street, house_number) do
    if Regex.match?(~r/^\d+[a-zA-Z]?\s+[a-zA-Z]/, street) do
      {extracted_street, extracted_num} = TitleBuilder.extract_street_and_number(street)
      {extracted_street, if(house_number != "", do: house_number, else: extracted_num)}
    else
      {street, house_number}
    end
  end

  defp prepare_geofence(addresses, raw_polygon, radius_meters) do
    normalized_vertices = Geofence.normalize_polygon_vertices(raw_polygon || [])

    if length(normalized_vertices) >= 3 do
      case Geofence.polygon_to_wkt(normalized_vertices) do
        {:ok, wkt} ->
          {:ok, %{polygon: normalized_vertices, wkt: wkt, radius_meters: radius_meters || 50}}

        {:error, _} ->
          {:ok, Geofence.default_polygon(addresses, radius_meters || 50)}
      end
    else
      {:ok, Geofence.default_polygon(addresses, radius_meters || 50)}
    end
  end

  defp validate_geofence_coverage(wkt, addresses) do
    case Geofence.validate_covers_addresses(wkt, addresses) do
      :ok ->
        :ok

      {:error, :addresses_outside_geofence} ->
        {:error,
         Ash.Error.Invalid.exception(
           errors: [
             Ash.Error.Changes.InvalidAttribute.exception(
               field: :geofence_polygon,
               message: "Die Geofence-Zone muss alle Teiladressen des Objekts umschließen."
             )
           ]
         )}

      {:error, _} ->
        {:error,
         Ash.Error.Invalid.exception(
           errors: [
             Ash.Error.Changes.InvalidAttribute.exception(
               field: :geofence_polygon,
               message: "Ungültige Geofence-Polygon-Geometrie."
             )
           ]
         )}
    end
  end

  defp insert_facility_addresses!(facility_id, normalized_addresses, actor, tenant_id) do
    Enum.each(normalized_addresses, fn addr ->
      FacilityAddress
      |> Ash.Changeset.for_create(
        :create_facility_address,
        Map.put(addr, :facility_id, facility_id),
        actor: actor,
        tenant: tenant_id
      )
      |> Ash.create(actor: actor, tenant: tenant_id)
      |> case do
        {:ok, _} -> :ok
        {:error, err} -> Repo.rollback(err)
      end
    end)
  end

  defp address_struct_to_map(%FacilityAddress{} = a) do
    %{
      street: a.street,
      house_number: a.house_number,
      postal_code: a.postal_code,
      city: a.city,
      country_code: a.country_code,
      latitude: a.latitude,
      longitude: a.longitude,
      is_primary: a.is_primary,
      provider_place_id: a.provider_place_id
    }
  end

  defp broadcast_tenant_event(tenant_id, event) do
    Phoenix.PubSub.broadcast(Faciqor.PubSub, "tenant:#{tenant_id}:operations", event)
  end
end
