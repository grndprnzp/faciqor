# Requirement-Spezifikation: Meilenstein 2 – Objekte, Adressen, Nummernkreise & Geo-Provider

- **Dokument-ID:** REQ-M2-FACILITIES
- **Version:** 1.0.0
- **Status:** Freigegeben für Implementierung (Coding Agents & Developers)
- **Betroffene Systemkomponenten:** `proto/`, `docker/`, `backend/` (`faciqor`, `faciqor_web`, `faciqor_grpc`), `cli/`, `docs/`

---

## 1. Zielsetzung & Scope

Der überwiegende Teil von **Faciqor** dreht sich um Liegenschaften, Objekte und Einsatzorte (`Facilities`). Jede Organisation (unabhängig von ihrem `primary_focus` als Eigentümer, Hausverwaltung oder Dienstleister) kann beliebig viele Objekte besitzen. Die erstellende Organisation wird als Mandant (`tenant_id` / Owner) eingetragen.

Meilenstein 2 schafft die fachliche und technische Grundlage für:
1. Die **Anlage und Verwaltung von Objekten (`Facility`)** samt komplexer Grundstücksstrukturen (Einzeladressen, Eckgrundstücke über mehrere Straßen, Hausnummern-Bereiche mit geraden/ungeraden Folgen und Buchstabensuffixen) mit je eigenen verifizierten Geokoordinaten (`FacilityAddress`).
2. Die **deterministische Titel-Synthese** aus den erfassten Teiladressen sowie die **automatische Vergabe eines unveränderlichen `business_key`** über mandantenspezifische **Nummernkreise (`NumberRange`)**.
3. Die **kartengestützte Geofence-Zonendefinition (`PostGIS Polygon`)** zur Lageverifikation des Objekts und späterer Vor-Ort-Leistungsnachweise.
4. Eine **strikt abstrahierte Geo- & Karten-Provider-Architektur (`Faciqor.Geo`)**, die standardmäßig **OpenStreetMap & Nominatim** nutzt und pro Organisation (oder gesammelt für alle eigenen Owner-Organisationen) auf **HERE Maps** umgestellt werden kann, ohne dass der funktionale Domänenkern Kenntnis vom eingesetzten Provider besitzt.

### 1.1 In Scope (Meilenstein 2)
- PostgreSQL **PostGIS**-Erweiterung (`GEOGRAPHY(Point, 4326)` für Teiladressen, `GEOGRAPHY(Polygon, 4326)` für Geofence-Zonen) inklusive strikter Mandanten-Isolation via Row-Level Security (`FORCE ROW LEVEL SECURITY`).
- Abstrakter Geo-Port (`Faciqor.Geo` & `@behaviour Faciqor.Geo.Provider`) mit Adaptern für **Nominatim** (Default) und **HERE Maps Geocoding & Search API v7** sowie Karten-Tile-Konfiguration (**OpenStreetMap** Default, **HERE Raster/Map Tiles**).
- Provider-Konfiguration in `/orgs/:handle/settings` (getrennt wählbar für Karte und Geo-Suche) inkl. Transaktions-Option *„Für alle Organisationen übernehmen, in denen ich Owner bin“*.
- Mandantenspezifische, typisierte **Nummernkreise (`NumberRange`)** mit Präfix/Suffix, Datums-Makros (`{{Jahr}}`, `{{Monat}}`, `{{Tag}}`), Startwert, aktuellem Wert, Schrittweite und automatischem Default-Nummernkreis (`OBJ-1000`, Schrittweite `1`) bei Organisationsanlage.
- Kombinierter Erfassungs-Workflow für **Einzeladressen, Eckgrundstücke und Hausnummern-Bereiche/Listen** (`10-14`, `10a-c`, `123, 125, 127`, Filter: alle / gerade / ungerade) mit Einzel-Geocodierung jeder Unter-Adresse und **Mehrfachtreffer-Auswahl** im Web-UI.
- Deterministische, schreibgeschützte **Titel-Synthese** aus den Teiladressen (`Hauptstraße 10-13`, `Main Street 123,125,127`, `Lauterberger Straße 32 - Walkenrieder Straße 4`).
- Interaktive **Leaflet-Kartenansicht (`FacilityMap` JS-Hook)** im Web-UI zur Anzeige aller Teiladressen-Marker und zur Bearbeitung der **Geofence-Zone** (automatischer 50m-Standardvorschlag um alle Teiladressen, anpassbar per Radius-Regler oder freier Polygon-Eckpunktbearbeitung).
- Lebenszyklus für Objekte: Bearbeiten von Teiladressen/Geofence durch `:owner` und `:member`, Archivieren (`archived_at`) sowie vollständiges Löschen (`destroy`) durch `:owner`, sofern keine Buchungen/Aufträge verknüpft sind (`:guest` hat reinen Lesezugriff).
- gRPC-Service (`OperationsService` in `proto/faciqor/v1/operations.proto`) und Go-CLI (`cli/`) für CRUD von Objekten, Nummernkreisen und Provider-Settings (interaktive Karte und Live-Autocomplete bleiben exklusiv im Web-UI `faciqor_web`).

### 1.2 Out of Scope (Folgemeilensteine)
- Binnenstruktur von Gebäuden (Aufgänge, Etagen, Wohn-/Gewerbeeinheiten, Zähler) -> folgt im nächsten Schritt aufbauend auf `Facility`.
- Mobile GPS-Check-in-Erfassung (`mobile/`) gegen die gespeicherte `geofence_zone`.

---

## 2. Architektur- & Technologie-Vorgaben

1. **Datenbank & PostGIS:**
   - Lokaler Container in `docker/compose.yml` nutzt `postgis/postgis:16-3.4-alpine` (PostgreSQL 16 mit vorinstallierter `postgis`-Extension).
   - `Faciqor.Repo.installed_extensions/0` aktiviert `"uuid-ossp"`, `"citext"` und `"postgis"`.
   - Elixir-seitig werden `geo` und `geo_postgis` für WKT/WKB/GeoJSON-Serialisierung und Ecto-Typen eingesetzt.
2. **Strikte Dezimalpräzision (Keine Floats – `AGENTS.md` § 5.1):**
   - Weder in Elixir, noch in PostgreSQL, Go oder Protobuf dürfen native `float`/`double`-Typen für Koordinaten oder Flächen verwendet werden.
   - Längen- und Breitengrade werden in den Ash-Ressourcen als `:decimal` (`NUMERIC(10, 7)`) geführt, in Protobuf als `string latitude` / `string longitude` übertragen und für räumliche Abfragen parallel in PostGIS-Spalten (`GEOGRAPHY(Point, 4326)` bzw. `GEOGRAPHY(Polygon, 4326)`) persistiert.
3. **Mandanten-Isolation & RLS (`AGENTS.md` § 2.1):**
   - Alle mandantenbezogenen Tabellen (`facilities`, `facility_addresses`, `number_ranges`) besitzen `tenant_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE`.
   - Auf allen Tabellen wird `ENABLE ROW LEVEL SECURITY` und `FORCE ROW LEVEL SECURITY` samt restriktiver `tenant_isolation_policy` auf `current_setting('app.current_tenant_id', true)::UUID` aktiviert.
   - Alle Ash-Ressourcen in `Faciqor.Operations` deklarieren `multitenancy strategy: :attribute, attribute: :tenant_id, global?: false`.
4. **Provider-Abstraktion (`Faciqor.Geo`):**
   - `Faciqor.Operations` kennt weder Nominatim/OpenStreetMap noch HERE Maps.
   - Alle Geocoding-Aufrufe laufen über `Faciqor.Geo` gegen das Behaviour `Faciqor.Geo.Provider`, welches normierte Domänenstrukturen (`%Faciqor.Geo.AddressCandidate{}`) zurückgibt.
5. **LiveView DOM-Isolation (`AGENTS.md` § 4.4):**
   - Der Karten-Container für Leaflet trägt zwingend `phx-update="ignore"` und eine feste Mindesthöhe (`h-96` / `min-h-[24rem]`), um Morphdom-Konflikte und `0px`-Höhenkollaps zu verhindern.

---

## 3. Domänenmodell & Ash-Ressourcen

### 3.1 Erweiterung `Faciqor.Accounts.Organization` (Tabelle: `organizations`)

Zur Speicherung der Karten- und Geo-Such-Provider pro Organisation wird `organizations` um folgende Attribute ergänzt:

| Attribut | Typ | Pflicht | Default | Constraints / Beschreibung |
| :--- | :--- | :--- | :--- | :--- |
| `map_provider` | `:atom` | Ja | `:openstreetmap` | Enum: `:openstreetmap`, `:here`. Steuert den Karten-Tile-Anbieter im Web-UI. |
| `geocoding_provider` | `:atom` | Ja | `:nominatim` | Enum: `:nominatim`, `:here`. Steuert den Anbieter für Adresssuche & Geocodierung. |
| `here_api_key` | `:string` | Nein | `nil` | `sensitive?: true`. Erforderlich, sobald `map_provider == :here` oder `geocoding_provider == :here` gewählt wird. |

**Aktionen auf `Organization`:**
- `update_geo_settings`:
  - Akzeptiert `:map_provider`, `:geocoding_provider`, `:here_api_key` sowie das Argument `apply_to_all_owned_orgs` (`:boolean`, Default: `false`).
  - Validiert, dass bei Wahl von `:here` (für Karte oder Geo-Suche) ein nicht-leerer `here_api_key` hinterlegt ist.
  - Wenn `apply_to_all_owned_orgs == true`, werden in derselben Datenbank-Transaktion alle aktiven Organisationen (`deleted_at == nil`), in denen der aktuelle `actor` die Rolle `:owner` hält, mit denselben Provider-Einstellungen aktualisiert.
- Bei `create_organization` wird in einem `after_action`-Hook automatisch der Standard-Nummernkreis für Objekte (`entity_type: :facility`, `prefix: "OBJ-"`, `start_value: 1000`, `step: 1`) für die neue Organisation angelegt.

---

### 3.2 Resource: `Faciqor.Operations.NumberRange` (Tabelle: `number_ranges`)

Verwaltet die Nummernkreise einer Organisation im Konfigurationsbereich.

| Attribut | Typ | Pflicht | Default | Constraints / Beschreibung |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `:uuid` | Ja | `uuid_v4()` | Primary Key. |
| `tenant_id` | `:uuid` | Ja | - | Foreign Key -> `organizations.id` (Multi-Tenancy Attribute & RLS). |
| `entity_type` | `:atom` | Ja | `:facility` | Enum: `[:facility]` (später erweiterbar um `:work_order`, `:invoice`). |
| `prefix` | `:string` | Nein | `"OBJ-"` | Optionales Präfix. Unterstützt Makros `{{Jahr}}`, `{{Monat}}`, `{{Tag}}`. |
| `start_value` | `:integer` | Ja | `1000` | Startwert (`> 0`, z. B. `1` oder `1000`). |
| `current_value` | `:integer` | Nein | `nil` | Zuletzt vergebener Zählerwert (`nil`, solange noch kein Schlüssel vergeben wurde). |
| `step` | `:integer` | Ja | `1` | Schrittweite (`> 0`, z. B. `1` oder `10`). |
| `suffix` | `:string` | Nein | `""` | Optionales Suffix. Unterstützt Makros `{{Jahr}}`, `{{Monat}}`, `{{Tag}}`. |
| `inserted_at` / `updated_at` | `:utc_datetime_usec` | Ja | - | Automatische Zeitstempel. |

- **Unique Identity:** `unique_index [:tenant_id, :entity_type]` (ein aktiver Nummernkreis pro Entitätstyp und Organisation).
- **Format-Regel:** `{Präfix}{AktuellerWert}{Suffix}` (z. B. `OG-1000-A` oder `OBJ-{{Jahr}}-1000`).
- **Makro-Auflösung (zum Zeitpunkt der Vergabe in UTC bzw. Organisations-Zeitzone):**
  - `{{Jahr}}` $\rightarrow$ 4-stelliges Jahr (z. B. `2026`)
  - `{{Monat}}` $\rightarrow$ 2-stelliger Monat mit führender Null (`01` bis `12`)
  - `{{Tag}}` $\rightarrow$ 2-stelliger Tag mit führender Null (`01` bis `31`)
- **Atomare Zähler-Vergabe (`allocate_next_key/3`):**
  - Ist `current_value == nil`, wird als erster Wert `start_value` verwendet und `current_value = start_value` gespeichert.
  - Ist `current_value != nil`, wird `next_val = max(current_value + step, start_value)` berechnet und atomar per `UPDATE number_ranges SET current_value = ... WHERE tenant_id = $1 AND entity_type = 'facility' RETURNING current_value` fortgeschrieben.

---

### 3.3 Resource: `Faciqor.Operations.Facility` (Tabelle: `facilities`)

Repräsentiert die logische Einheit eines Objekts / Grundstücks (Einzeladresse, mehrere Hausnummern oder Eckgrundstück).

| Attribut | Typ | Pflicht | Default | Constraints / Beschreibung |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `:uuid` | Ja | `uuid_v4()` | Primary Key. |
| `tenant_id` | `:uuid` | Ja | - | Foreign Key -> `organizations.id` (Erstellende Organisation = Owner / RLS). |
| `business_key` | `:ci_string` | Ja | - | Aus dem Nummernkreis generierter Schlüssel (`citext`), nach Anlage **unveränderlich** (`readonly`). |
| `title` | `:string` | Ja | - | Automatisch und deterministisch aus den Teiladressen berechneter Objekttitel (`readonly`). |
| `geofence_zone` | `Geo.PostGIS.Geometry` | Ja | - | PostGIS `GEOGRAPHY(Polygon, 4326)` (SRID 4326). Definiert die Geofence-Zone um das Objekt. |
| `geofence_radius_meters` | `:integer` | Nein | `50` | Zuletzt gewählter Puffer-Radius in Metern (falls Zone über Radius-Modus erzeugt wurde). |
| `archived_at` | `:utc_datetime_usec` | Nein | `nil` | Gesetzt, wenn das Objekt archiviert/deaktiviert wurde. |
| `inserted_at` / `updated_at` | `:utc_datetime_usec` | Ja | - | Automatische Zeitstempel. |

- **Unique Identity:** `unique_index [:tenant_id, :business_key]` (BusinessKey ist pro Organisation eindeutig).
- **Spatial Index:** `GIST (geofence_zone)` für schnelle PostGIS-Abfragen.
- **Beziehungen:**
  - `belongs_to :organization, Faciqor.Accounts.Organization, source_attribute: :tenant_id`
  - `has_many :addresses, Faciqor.Operations.FacilityAddress` (sortiert nach `sort_order ASC`)

---

### 3.4 Resource: `Faciqor.Operations.FacilityAddress` (Tabelle: `facility_addresses`)

Speichert jede einzelne zu einem Objekt gehörende Hausnummer / Teiladresse inklusive eigener PostGIS-Punktkoordinaten.

| Attribut | Typ | Pflicht | Default | Constraints / Beschreibung |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `:uuid` | Ja | `uuid_v4()` | Primary Key. |
| `tenant_id` | `:uuid` | Ja | - | Foreign Key -> `organizations.id` (RLS). |
| `facility_id` | `:uuid` | Ja | - | Foreign Key -> `facilities.id` (`ON DELETE CASCADE`). |
| `street` | `:string` | Ja | - | Straßenname (z. B. `"Lauterberger Straße"`, `"Main Street"`). |
| `house_number` | `:string` | Ja | - | Vollständige Hausnummer inkl. evtl. Buchstabensuffix (z. B. `"32"`, `"10a"`). |
| `house_number_numeric` | `:integer` | Ja | - | Numerischer Kern der Hausnummer (z. B. `32`, `10`) für korrekte Sortierung und Bereichserkennung. |
| `house_number_suffix` | `:string` | Nein | `nil` | Normalisierter Buchstabensuffix in Kleinbuchstaben (z. B. `"a"`, `"b"` oder `nil`). |
| `postal_code` | `:string` | Ja | - | Postleitzahl (z. B. `"10115"`). |
| `city` | `:string` | Ja | - | Ort / Stadt (z. B. `"Berlin"`). |
| `country_code` | `:string` | Ja | `"DE"` | ISO 3166-1 alpha-2 Ländercode. |
| `latitude` | `:decimal` | Ja | - | Breitengrad (`NUMERIC(10, 7)`), Bereich `-90.0` bis `90.0`. |
| `longitude` | `:decimal` | Ja | - | Längengrad (`NUMERIC(10, 7)`), Bereich `-180.0` bis `180.0`. |
| `location` | `Geo.PostGIS.Geometry` | Ja | - | PostGIS `GEOGRAPHY(Point, 4326)` aus `(longitude, latitude)`. |
| `is_primary` | `:boolean` | Ja | `false` | Kennzeichnet die führende Hauptadresse des Objekts. |
| `sort_order` | `:integer` | Ja | `0` | Reihenfolge der Adressen (bestimmt Straßenreihenfolge bei Eckgrundstücken). |
| `provider_place_id` | `:string` | Nein | `nil` | Optionale Referenz-ID aus dem Geocoding-Ergebnis. |
| `inserted_at` / `updated_at` | `:utc_datetime_usec` | Ja | - | Automatische Zeitstempel. |

- **Spatial Index:** `GIST (location)` sowie Index auf `(tenant_id, facility_id)`.

---

## 4. Fachliche Geschäftslogik & Algorithmen

### 4.1 Rollen- & Berechtigungsmatrix (`Ash.Policy.Authorizer`)

Innerhalb des Mandantenkontexts (`tenant_id`) gelten folgende Berechtigungen:

| Aktion / Ressource | `:owner` | `:member` | `:guest` | Nicht-Mitglied |
| :--- | :---: | :---: | :---: | :---: |
| **Objekte & Teiladressen lesen (`read`)** | ✅ | ✅ | ✅ | ❌ |
| **Objekt anlegen (`create_facility`)** | ✅ | ✅ | ❌ | ❌ |
| **Objekt bearbeiten (`update_facility`: Adressen & Geofence)** | ✅ | ✅ | ❌ | ❌ |
| **Objekt archivieren / reaktivieren (`archive_facility` / `unarchive_facility`)** | ✅ | ✅ | ❌ | ❌ |
| **Objekt löschen (`destroy_facility`, nur ohne Buchungen/Aufträge)** | ✅ | ❌ | ❌ | ❌ |
| **Nummernkreise & Geo-Provider lesen (`read`)** | ✅ | ✅ | ✅ (`readonly`) | ❌ |
| **Nummernkreise & Geo-Provider ändern (`update`)** | ✅ | ❌ | ❌ | ❌ |

---

### 4.2 Deterministische Titel-Synthese (`Faciqor.Operations.TitleBuilder`)

Der Titel (`facility.title`) wird bei jeder Anlage und Adressänderung automatisch aus der geordneten Liste der `FacilityAddress`-Einträge berechnet und kann nicht manuell überschrieben werden:

1. **Gruppierung nach Straße:**
   - Alle Teiladressen werden unter Beibehaltung der Reihenfolge des ersten Auftretens der jeweiligen Straße (`street`) gruppiert.
   - Innerhalb derselben Straße werden die Hausnummern aufsteigend nach `(house_number_numeric, house_number_suffix || "")` sortiert und dedupliziert.
2. **Formatierung der Hausnummern-Folgen innerhalb einer Straße:**
   - Zwei aufeinanderfolgende Hausnummern $A$ und $B$ gelten genau dann als **lückenlos zusammenhängend (ohne Unterbrechung)**, wenn:
     - **Rein numerisch (`suffix == nil`):** $B.\text{num} == A.\text{num} + 1$ (z. B. `10, 11, 12, 13`), **oder**
     - **Gleiche Basisnummer mit direkt folgendem Buchstabensuffix:** $B.\text{num} == A.\text{num}$ und $\text{codepoint}(B.\text{suffix}) == \text{codepoint}(A.\text{suffix}) + 1$ (z. B. `10a, 10b, 10c`), **oder**
     - **Explizite Straßen-Sequenz ohne fehlende Zwischennummer im erfassten Lauf:** Wenn eine zusammenhängende Sequenz von mindestens 2 aufeinanderfolgenden Hausnummern vorliegt, wird sie mit Bindestrich `<Start>-<Ende>` zusammengefasst.
   - **Unterbrochene Folgen** (z. B. nur ungerade `123, 125, 127` oder nur gerade `10, 12, 14` mit Differenz $> 1$) werden mit Komma ohne Leerzeichen verbunden: `123,125,127`.
   - Gemischte Folgen kombinieren beide Regeln (z. B. `10, 11, 12, 15` $\rightarrow$ `10-12,15`).
   - Straßenname und formatierte Hausnummern werden als `<Straße> <FormatierteNummern>` zusammengesetzt (unabhängig davon, ob der Geo-Provider im englischen Format `123 Main Street` geliefert hat).
3. **Verkettung mehrerer Straßen (Eckgrundstücke):**
   - Umfasst das Objekt mehrere Straßen, werden die jeweiligen `<Straße> <FormatierteNummern>`-Blöcke durch ` - ` (Leerzeichen, Bindestrich, Leerzeichen) verbunden.

**Referenzbeispiele (Verbindliche Testfälle):**
- Einzeladresse: `Hauptstraße` + `[10]` $\rightarrow$ `Hauptstraße 10`
- Eckgrundstück: `Lauterberger Straße 32` & `Walkenrieder Straße 4` $\rightarrow$ `Lauterberger Straße 32 - Walkenrieder Straße 4`
- Mehrere Hausnummern mit Unterbrechung: `123 Main Street`, `125 Main Street`, `127 Main Street` $\rightarrow$ `Main Street 123,125,127`
- Mehrere Hausnummern ohne Unterbrechung: `Hauptstraße 10` bis `13` $\rightarrow$ `Hauptstraße 10-13`
- Buchstabensuffixe ohne Unterbrechung: `Gartenweg 10a`, `10b`, `10c` $\rightarrow$ `Gartenweg 10a-10c`

---

### 4.3 Hausnummern-Expansion & Einzel-Geocodierung (`Faciqor.Operations.AddressExpander`)

Um Grundstücke mit mehreren Hausnummern effizient anzulegen, unterstützt das System neben dem Hinzufügen einzelner Adressen einen Bereichs-/Listen-Parser:
- **Unterstützte Eingabemuster für Hausnummern einer Straße:**
  - Einzelnummer: `32`, `10a`
  - Komma-Liste: `123, 125, 127` oder `10a, 10b, 12`
  - Numerischer Bereich: `10-13` mit Modus:
    - `:all` (Standard, alle Nummern: `10, 11, 12, 13`)
    - `:even` (nur gerade Nummern: `10, 12`)
    - `:odd` (nur ungerade Nummern: `11, 13`)
  - Buchstabensuffix-Bereich: `10a-10c` oder `10a-c` $\rightarrow$ `["10a", "10b", "10c"]`
- **Einzel-Geocodierung:**
  - Für jede expandierte Hausnummer wird über den konfigurierten Geo-Provider (`Faciqor.Geo.search_address/3`) der spezifische Koordinatenpunkt (`latitude`, `longitude`) aufgelöst.
  - Liefert der Provider für eine Adresse **Mehrfachtreffer** (z. B. gleichnamige Straße in verschiedenen Ortsteilen/Städten), markiert das Formular diesen Eintrag als „Auswahl erforderlich“ und lässt den Nutzer den exakten Treffer aus der Kandidatenliste wählen.

---

### 4.4 Geofence-Zone & PostGIS-Geometrie (`Faciqor.Geo.Geofence`)

1. **Automatischer Vorschlag (Default-Geofence):**
   - Sobald mindestens eine `FacilityAddress` mit Koordinaten vorhanden ist, berechnet `Faciqor.Geo.Geofence.default_polygon/2` ein regelmäßiges Puffer-Polygon (Standard-Radius: `50` Meter, 32 Segmente / konvexe Hülle um alle Teiladressen-Punkte in SRID 4326).
2. **Interaktive Anpassung im Karten-UI:**
   - **Radius-Modus:** Anpassung des Puffers (`15m` bis `500m`) per Slider/Input berechnet das umschließende Polygon live neu.
   - **Polygon-Modus:** Der Nutzer kann die Eckpunkte des Polygons direkt auf der Karte verschieben oder ein neues Polygon zeichnen.
3. **PostGIS-Integritätsprüfung:**
   - Beim Speichern eines Objekts wird validiert, dass `geofence_zone` ein geschlossenes, valides `Geo.Polygon` (`srid: 4326`) ist und alle zugehörigen `FacilityAddress`-Punkte innerhalb bzw. auf dem Rand des Polygons liegen (`ST_Covers(geofence_zone, location)`).

---

### 4.5 Abstrakter Geo-Provider (`Faciqor.Geo`)

```elixir
defmodule Faciqor.Geo.AddressCandidate do
  @enforce_keys [:street, :house_number, :postal_code, :city, :country_code, :latitude, :longitude]
  defstruct [
    :provider_place_id,
    :formatted_label,
    :street,
    :house_number,
    :postal_code,
    :city,
    :country_code,
    :latitude,   # Decimal.t()
    :longitude   # Decimal.t()
  ]
end

defmodule Faciqor.Geo.Provider do
  @callback search(query :: String.t(), opts :: keyword()) ::
              {:ok, [Faciqor.Geo.AddressCandidate.t()]} | {:error, term()}
end
```

- **Implementierungen:**
  1. `Faciqor.Geo.Providers.Nominatim`: Nutzt die OpenStreetMap Nominatim JSON API (`/search?format=jsonv2&addressdetails=1`) mit sauberem `User-Agent`-Header und Dezimal-Konvertierung.
  2. `Faciqor.Geo.Providers.HereMaps`: Nutzt die HERE Geocoding & Search API v7 (`https://geocode.search.hereapi.com/v1/geocode`) mit dem in der Organisation hinterlegten `here_api_key`.
- **Testbarkeit:** In Test-Umgebungen (`config/test.exs`) kann ein deterministischer `Faciqor.Geo.Providers.Mock`-Adapter injiziert werden, sodass sämtliche Unit-, LiveView- und CLI-Tests komplett offline und reproduzierbar laufen.

---

## 5. Schnittstellenvertrag: gRPC & Go-CLI (`proto/` & `cli/`)

### 5.1 Protocol Buffers (`proto/faciqor/v1/operations.proto`)

```protobuf
syntax = "proto3";

package faciqor.v1;
option go_package = "faciqor/pkg/api/v1;v1";

enum MapProvider {
  MAP_PROVIDER_UNSPECIFIED = 0;
  MAP_PROVIDER_OPENSTREETMAP = 1;
  MAP_PROVIDER_HERE = 2;
}

enum GeocodingProvider {
  GEOCODING_PROVIDER_UNSPECIFIED = 0;
  GEOCODING_PROVIDER_NOMINATIM = 1;
  GEOCODING_PROVIDER_HERE = 2;
}

enum NumberRangeEntityType {
  NUMBER_RANGE_ENTITY_TYPE_UNSPECIFIED = 0;
  NUMBER_RANGE_ENTITY_TYPE_FACILITY = 1;
}

service OperationsService {
  // Geo Provider Configuration (per Organization or bulk for all owned orgs)
  rpc GetGeoProviderConfig (GetGeoProviderConfigRequest) returns (GeoProviderConfigResponse);
  rpc UpdateGeoProviderConfig (UpdateGeoProviderConfigRequest) returns (GeoProviderConfigResponse);

  // Number Ranges
  rpc GetNumberRange (GetNumberRangeRequest) returns (NumberRangeResponse);
  rpc UpdateNumberRange (UpdateNumberRangeRequest) returns (NumberRangeResponse);

  // Facilities CRUD
  rpc ListFacilities (ListFacilitiesRequest) returns (ListFacilitiesResponse);
  rpc GetFacility (GetFacilityRequest) returns (FacilityResponse);
  rpc CreateFacility (CreateFacilityRequest) returns (FacilityResponse);
  rpc UpdateFacility (UpdateFacilityRequest) returns (FacilityResponse);
  rpc ArchiveFacility (ArchiveFacilityRequest) returns (FacilityResponse);
  rpc UnarchiveFacility (UnarchiveFacilityRequest) returns (FacilityResponse);
  rpc DeleteFacility (DeleteFacilityRequest) returns (DeleteFacilityResponse);
}

message GeoCoordinate {
  string latitude = 1;  // Decimal string, e.g. "52.5200066"
  string longitude = 2; // Decimal string, e.g. "13.4049540"
}

message FacilityAddressInput {
  string street = 1;
  string house_number = 2;
  string postal_code = 3;
  string city = 4;
  optional string country_code = 5;
  optional string latitude = 6;
  optional string longitude = 7;
  optional bool is_primary = 8;
}

message FacilityAddressItem {
  string id = 1;
  string street = 2;
  string house_number = 3;
  string postal_code = 4;
  string city = 5;
  string country_code = 6;
  string latitude = 7;
  string longitude = 8;
  bool is_primary = 9;
  int32 sort_order = 10;
}

message GetGeoProviderConfigRequest {
  string org_id_or_handle = 1;
}

message UpdateGeoProviderConfigRequest {
  string org_id_or_handle = 1;
  optional MapProvider map_provider = 2;
  optional GeocodingProvider geocoding_provider = 3;
  optional string here_api_key = 4;
  bool apply_to_all_owned_orgs = 5;
}

message GeoProviderConfigResponse {
  string organization_id = 1;
  string organization_handle = 2;
  MapProvider map_provider = 3;
  GeocodingProvider geocoding_provider = 4;
  bool has_here_api_key = 5;
  repeated string updated_organization_handles = 6;
}

message GetNumberRangeRequest {
  string org_id_or_handle = 1;
  NumberRangeEntityType entity_type = 2;
}

message UpdateNumberRangeRequest {
  string org_id_or_handle = 1;
  NumberRangeEntityType entity_type = 2;
  optional string prefix = 3;
  optional int64 start_value = 4;
  optional int64 current_value = 5;
  optional int64 step = 6;
  optional string suffix = 7;
}

message NumberRangeResponse {
  string id = 1;
  string organization_id = 2;
  NumberRangeEntityType entity_type = 3;
  string prefix = 4;
  int64 start_value = 5;
  optional int64 current_value = 6;
  int64 step = 7;
  string suffix = 8;
  string preview_next_key = 9;
}

message ListFacilitiesRequest {
  string org_id_or_handle = 1;
  bool include_archived = 2;
}

message ListFacilitiesResponse {
  repeated FacilityResponse facilities = 1;
}

message GetFacilityRequest {
  string org_id_or_handle = 1;
  string id_or_business_key = 2;
}

message CreateFacilityRequest {
  string org_id_or_handle = 1;
  repeated FacilityAddressInput addresses = 2;
  repeated GeoCoordinate geofence_polygon = 3;
  optional int32 geofence_radius_meters = 4;
}

message UpdateFacilityRequest {
  string org_id_or_handle = 1;
  string id_or_business_key = 2;
  repeated FacilityAddressInput addresses = 3;
  repeated GeoCoordinate geofence_polygon = 4;
  optional int32 geofence_radius_meters = 5;
}

message ArchiveFacilityRequest {
  string org_id_or_handle = 1;
  string id_or_business_key = 2;
}

message UnarchiveFacilityRequest {
  string org_id_or_handle = 1;
  string id_or_business_key = 2;
}

message DeleteFacilityRequest {
  string org_id_or_handle = 1;
  string id_or_business_key = 2;
}

message DeleteFacilityResponse {
  bool deleted = 1;
}

message FacilityResponse {
  string id = 1;
  string organization_id = 2;
  string business_key = 3;
  string title = 4;
  repeated FacilityAddressItem addresses = 5;
  repeated GeoCoordinate geofence_polygon = 6;
  int32 geofence_radius_meters = 7;
  optional string archived_at = 8;
  string inserted_at = 9;
  string updated_at = 10;
}
```

### 5.2 Verbindliche Go-CLI-Befehle (`cli/`)

```bash
# Objekte (Facilities) verwalten
faciqor facility list --org <handle> [--include-archived]
faciqor facility show <id-or-business-key> --org <handle>
faciqor facility create --org <handle> --address "Hauptstraße 10-13, 10115 Berlin" [--address "Nebenstraße 2, 10115 Berlin"] [--radius 50]
faciqor facility update <id-or-business-key> --org <handle> [--address "..."] [--radius 75]
faciqor facility archive <id-or-business-key> --org <handle>
faciqor facility unarchive <id-or-business-key> --org <handle>
faciqor facility delete <id-or-business-key> --org <handle> [--yes]

# Nummernkreise der Organisation verwalten
faciqor org number-range show <org-handle>
faciqor org number-range update <org-handle> [--prefix "OG-{{Jahr}}-"] [--start 1000] [--step 1] [--suffix "-A"]

# Karten- & Geo-Provider der Organisation verwalten
faciqor org geo-provider show <org-handle>
faciqor org geo-provider update <org-handle> [--map-provider osm|here] [--geocoding-provider nominatim|here] [--here-api-key "..."] [--apply-all-owned]
```

---

## 6. UI/UX-Spezifikation für `faciqor_web` (Phoenix LiveView)

### 6.1 Routenstruktur (`backend/lib/faciqor_web/router.ex`)
Innerhalb der `live_session :authenticated` werden folgende mandantenbezogene Routen bereitgestellt:
- `live "/orgs/:handle/facilities", FacilityIndexLive, :index` – Objektübersicht der Organisation mit Suche, Archiv-Filter und Direktaktionen.
- `live "/orgs/:handle/facilities/new", FacilityFormLive, :new` – Formular zur Neuanlage eines Objekts inkl. Geo-Suche, Mehrfachtreffer-Auswahl, Bereichs-Expansion und interaktiver Geofence-Karte.
- `live "/orgs/:handle/facilities/:id", FacilityFormLive, :edit` – Detail- und Bearbeitungsansicht eines Objekts (`readonly`-Modus für `:guest`).
- Erweiterung von `live "/orgs/:handle/settings", OrgSettingsLive, :edit` um:
  - **Sektion C – Nummernkreise (BusinessKey-Konfiguration):** Pflege von `prefix`, `start_value`, `current_value`, `step`, `suffix` inkl. Live-Vorschau des nächsten generierten Schlüssels (z. B. `OBJ-2026-1000` in `fq-mono`).
  - **Sektion D – Kartenanbieter & Geo-Suche:** Auswahl von Kartenanbieter (`OpenStreetMap` vs. `HERE Maps`) und Geo-Suche (`Nominatim` vs. `HERE Maps`), Eingabefeld für `HERE API-Schlüssel` sowie Checkbox *„Einstellung für alle Organisationen übernehmen, in denen ich Owner bin“*.
  - Gefahrenzone rückt auf **Sektion E**.

### 6.2 Objekt-Formular & Karten-Interaktion (`FacilityFormLive`)
1. **Kopfzeile & Identität:**
   - Zeigt bei bestehenden Objekten den unveränderlichen `BusinessKey` (`<.input readonly={true} monospace={true} />`) und bei Neuanlage die Vorschau des nächsten Nummernkreis-Schlüssels.
   - Zeigt den automatisch aus den Teiladressen berechneten **Objekt-Titel** (`<.input readonly={true} />`) in Echtzeit an, sobald Teiladressen hinzugefügt, geändert oder entfernt werden.
2. **Adress-Erfassung & Mehrfachtreffer-Dialog:**
   - **Such- & Expansionsleiste:** Eingabe einer Adresse oder Straße mit Hausnummer(n) (z. B. `Lauterberger Straße 32, Berlin` oder `Hauptstraße 10-13, Berlin` + Filter `Alle` / `Nur gerade` / `Nur ungerade`).
   - **Mehrfachtreffer-Hinweis:** Liefert die Geo-Suche mehrere Kandidaten für eine Eingabe, erscheint eine hervorgehobene Auswahlbox (`--fq-status-warning`), in der der Nutzer den gewünschten Treffer per Klick übernimmt.
   - **Teiladressen-Liste:** Tabellarische Darstellung aller erfassten `FacilityAddress`-Einträge mit Straße, Hausnummer, PLZ/Ort, verifizierten Koordinaten (`latitude, longitude` in `fq-mono tabular-nums`), `Hauptadresse`-Markierung und Entfernen-Aktion.
3. **Kartenansicht & Geofence-Editor (`FacilityMap` JS-Hook):**
   - Rendert eine interaktive Karte (`phx-update="ignore"`, `h-96`) mit dem in der Organisation konfigurierten Kartenanbieter (`OpenStreetMap` oder `HERE Maps`).
   - Zeigt für jede Teiladresse einen eigenen Pin-Marker (mit Popup der Hausnummer und Koordinaten).
   - Visualisiert die **Geofence-Zone** als farbig hinterlegtes Polygon um die Teiladressen und erlaubt die Anpassung über:
     - **Radius-Regler (`15m` – `500m`):** Berechnet das Puffer-Polygon automatisch um alle Teiladressen neu.
     - **Polygon-Eckpunkte auf der Karte verschieben:** Ermöglicht den exakten Zuschnitt auf Grundstücksgrenzen (z. B. bei Eckgrundstücken).

---

## 7. Qualitätssicherung, Tests & Akzeptanzkriterien (Definition of Done)

### 7.1 Automatisierte Backend- & Domänentests (`backend/test/faciqor/operations/`)
1. **Titel-Synthese (`TitleBuilderTest`):**
   - Verifiziert exakt die drei Spezifikations-Beispiele (`Lauterberger Straße 32 - Walkenrieder Straße 4`, `Main Street 123,125,127`, `Hauptstraße 10-13`) sowie Buchstabensuffixe (`10a-10c`) und gemischte Folgen.
2. **Nummernkreise & Makros (`NumberRangeTest`):**
   - Prüft den automatischen Default-Nummernkreis bei `create_organization`.
   - Prüft die Makro-Ersetzung (`{{Jahr}}`, `{{Monat}}`, `{{Tag}}`), Startwert (`start_value` beim 1. Objekt), Schrittweite (`+ step` beim 2. Objekt) und die Eindeutigkeit pro Mandant.
3. **RLS & Multi-Tenancy-Isolation (`FacilityTest`):**
   - Prüft, dass Organisation A keine Objekte oder Nummernkreise von Organisation B lesen oder manipulieren kann.
   - Prüft die Rollenmatrix (`:owner`, `:member` schreiben/archivieren; `:owner` löscht; `:guest` nur lesen).
   - Prüft die PostGIS-Speicherung (`GEOGRAPHY(Point, 4326)` und `GEOGRAPHY(Polygon, 4326)`) sowie die `ST_Covers`-Validierung der Geofence-Zone.
4. **Provider-Abstraktion & Bulk-Update (`GeoProviderConfigTest`):**
   - Prüft, dass `apply_to_all_owned_orgs: true` ausschließlich diejenigen Organisationen aktualisiert, in denen der User `:owner` ist (nicht `:member`-Organisationen oder fremde Organisationen).

### 7.2 LiveView-UI-Tests (`backend/test/faciqor_web/live/`)
1. **Objekt-Anlage & Mehrfachtreffer-Auswahl:**
   - Testet die Adresssuche auf `/orgs/:handle/facilities/new`, den Hinweis und die Auswahl bei Mehrfachtreffern, die Bereichs-Expansion (`10-13`), die Live-Vorschau des Titels und das Speichern des Objekts.
2. **Organisations-Einstellungen (`/orgs/:handle/settings`):**
   - Testet das Bearbeiten des Nummernkreises inkl. Format-Vorschau und das Umschalten des Geo-Providers inkl. Bulk-Übernahme für alle Owner-Organisationen.

### 7.3 gRPC- & Go-CLI-Tests (`backend/test/faciqor_grpc/` & `cli/`)
1. **gRPC `OperationsService`:**
   - Testet `CreateFacility`, `ListFacilities`, `UpdateFacility`, `ArchiveFacility`, `DeleteFacility`, `GetNumberRange`, `UpdateNumberRange` und `UpdateGeoProviderConfig`.
2. **Go-CLI Unit-Tests (`cli/internal/cmd/`):**
   - Testet die neuen CLI-Subcommands (`faciqor facility ...`, `faciqor org number-range ...`, `faciqor org geo-provider ...`) inkl. `--json`-Ausgabe.
