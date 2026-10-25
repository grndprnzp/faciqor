defmodule Faciqor.Repo.Migrations.CreateFacilitiesNumberRangesAndGeoConfig do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS postgis;"

    # Ensure erp_app_user role exists for RLS policies per AGENTS.md § 2.1
    execute """
    DO $$
    BEGIN
      IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'erp_app_user') THEN
        CREATE ROLE erp_app_user NOBYPASSRLS;
      END IF;
    END
    $$;
    """

    # 1. Extend organizations with map_provider, geocoding_provider, here_api_key
    alter table(:organizations) do
      add :map_provider, :string, null: false, default: "openstreetmap"
      add :geocoding_provider, :string, null: false, default: "nominatim"
      add :here_api_key, :string
    end

    # 2. number_ranges
    create table(:number_ranges, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :tenant_id, references(:organizations, type: :uuid, on_delete: :delete_all), null: false
      add :entity_type, :string, null: false, default: "facility"
      add :prefix, :string, default: "OBJ-"
      add :start_value, :bigint, null: false, default: 1000
      add :current_value, :bigint
      add :step, :bigint, null: false, default: 1
      add :suffix, :string, default: ""
      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:number_ranges, [:tenant_id, :entity_type])

    execute "ALTER TABLE number_ranges ENABLE ROW LEVEL SECURITY;"
    execute "ALTER TABLE number_ranges FORCE ROW LEVEL SECURITY;"

    execute """
    CREATE POLICY tenant_isolation_policy ON number_ranges
      AS RESTRICTIVE
      FOR ALL
      TO erp_app_user
      USING (tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::UUID)
      WITH CHECK (tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::UUID);
    """

    # Seed default facility number_range for any existing organizations
    execute """
    INSERT INTO number_ranges (id, tenant_id, entity_type, prefix, start_value, current_value, step, suffix, inserted_at, updated_at)
    SELECT uuid_generate_v4(), id, 'facility', 'OBJ-', 1000, NULL, 1, '', NOW(), NOW()
    FROM organizations
    ON CONFLICT (tenant_id, entity_type) DO NOTHING;
    """

    # 3. facilities
    create table(:facilities, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :tenant_id, references(:organizations, type: :uuid, on_delete: :delete_all), null: false
      add :business_key, :citext, null: false
      add :title, :string, null: false
      add :geofence_wkt, :text, null: false
      add :geofence_polygon, :jsonb, null: false, default: "[]"
      add :geofence_radius_meters, :integer, null: false, default: 50
      add :archived_at, :utc_datetime_usec
      timestamps(type: :utc_datetime_usec)
    end

    execute "ALTER TABLE facilities ADD COLUMN geofence_zone GEOGRAPHY(Polygon, 4326) NOT NULL;"
    execute "CREATE INDEX facilities_geofence_zone_gist_idx ON facilities USING GIST (geofence_zone);"
    create unique_index(:facilities, [:tenant_id, :business_key])
    create index(:facilities, [:tenant_id])

    execute """
    CREATE OR REPLACE FUNCTION sync_facility_geofence_zone() RETURNS trigger AS $$
    BEGIN
      IF NEW.geofence_wkt IS NOT NULL AND NEW.geofence_wkt <> '' THEN
        NEW.geofence_zone := ST_GeogFromText('SRID=4326;' || NEW.geofence_wkt);
      END IF;
      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
    """

    execute """
    CREATE TRIGGER facilities_sync_geofence_zone_trg
      BEFORE INSERT OR UPDATE ON facilities
      FOR EACH ROW
      EXECUTE FUNCTION sync_facility_geofence_zone();
    """

    execute "ALTER TABLE facilities ENABLE ROW LEVEL SECURITY;"
    execute "ALTER TABLE facilities FORCE ROW LEVEL SECURITY;"

    execute """
    CREATE POLICY tenant_isolation_policy ON facilities
      AS RESTRICTIVE
      FOR ALL
      TO erp_app_user
      USING (tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::UUID)
      WITH CHECK (tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::UUID);
    """

    # 4. facility_addresses
    create table(:facility_addresses, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :tenant_id, references(:organizations, type: :uuid, on_delete: :delete_all), null: false
      add :facility_id, references(:facilities, type: :uuid, on_delete: :delete_all), null: false
      add :street, :string, null: false
      add :house_number, :string, null: false
      add :house_number_numeric, :integer, null: false, default: 0
      add :house_number_suffix, :string
      add :postal_code, :string, null: false
      add :city, :string, null: false
      add :country_code, :string, null: false, default: "DE"
      add :latitude, :decimal, precision: 10, scale: 7, null: false
      add :longitude, :decimal, precision: 10, scale: 7, null: false
      add :is_primary, :boolean, null: false, default: false
      add :sort_order, :integer, null: false, default: 0
      add :provider_place_id, :string
      timestamps(type: :utc_datetime_usec)
    end

    execute "ALTER TABLE facility_addresses ADD COLUMN location GEOGRAPHY(Point, 4326) NOT NULL;"
    execute "CREATE INDEX facility_addresses_location_gist_idx ON facility_addresses USING GIST (location);"
    create index(:facility_addresses, [:tenant_id, :facility_id])

    execute """
    CREATE OR REPLACE FUNCTION sync_facility_address_location() RETURNS trigger AS $$
    BEGIN
      NEW.location := ST_SetSRID(ST_MakePoint(NEW.longitude::double precision, NEW.latitude::double precision), 4326)::geography;
      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
    """

    execute """
    CREATE TRIGGER facility_addresses_sync_location_trg
      BEFORE INSERT OR UPDATE ON facility_addresses
      FOR EACH ROW
      EXECUTE FUNCTION sync_facility_address_location();
    """

    execute "ALTER TABLE facility_addresses ENABLE ROW LEVEL SECURITY;"
    execute "ALTER TABLE facility_addresses FORCE ROW LEVEL SECURITY;"

    execute """
    CREATE POLICY tenant_isolation_policy ON facility_addresses
      AS RESTRICTIVE
      FOR ALL
      TO erp_app_user
      USING (tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::UUID)
      WITH CHECK (tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::UUID);
    """
  end

  def down do
    execute "DROP TRIGGER IF EXISTS facility_addresses_sync_location_trg ON facility_addresses;"
    execute "DROP FUNCTION IF EXISTS sync_facility_address_location();"
    drop table(:facility_addresses)

    execute "DROP TRIGGER IF EXISTS facilities_sync_geofence_zone_trg ON facilities;"
    execute "DROP FUNCTION IF EXISTS sync_facility_geofence_zone();"
    drop table(:facilities)

    drop table(:number_ranges)

    alter table(:organizations) do
      remove :here_api_key
      remove :geocoding_provider
      remove :map_provider
    end
  end
end
