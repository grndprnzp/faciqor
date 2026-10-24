# Faciqor – Workspace- & Monorepo-Architektur-Referenz

> **Verbindliche Referenz für Entwickler und KI-Agenten**  
> Status: Genehmigt | Version: 1.0.0 | Geltungsbereich: Gesamtsystem (*Faciqor*)

---

## 1. Architektur-Prinzipien & Leitplanken

1. **Contract-First als Single Source of Truth:**  
   Sämtliche Schnittstellen zwischen Backend, CLI und mobilen Clients werden technologieunabhängig als Protocol Buffers in `proto/` definiert. Kein Client und kein Server implementiert API-Endpunkte ohne vorgängig versionierten Protobuf-Vertrag.
2. **Strikte Toolchain-Isolation im Polyglot-Monorepo:**  
   Trotz gemeinsamer Verwaltung im Monorepo existieren keine impliziten Code-Abhängigkeiten zwischen Elixir, Go und Flutter/Dart. Jede Komponente besitzt ihre eigene Paket- und Build-Konfiguration (`mix.exs`, `go.mod`, `pubspec.yaml`).
3. **Mandanten-Isolation (Row-Level Security & Ash Multi-Tenancy):**  
   Im Backend darf kein Datenzugriff ohne gesetzten Mandantenkontext erfolgen. Auf Datenbankebene wird dies über PostgreSQL RLS (`SET LOCAL app.current_tenant_id = $1`) und im Ash Framework über `multitenancy strategy: :attribute` erzwungen.
4. **Rechtssichere BetrKV- und GoBD-Konformität:**  
   Finanz- und Leistungsdaten werden nach dem Append-Only-Prinzip geführt (keine unprotokollierten `UPDATE`-Statements auf Buchungen). Tätigkeiten müssen bereits bei Erfassung strikt in umlagefähige Betriebskosten (§ 2 Nr. 14 BetrKV) und nicht umlagefähige Instandsetzung (§ 1 Abs. 2 BetrKV) getrennt werden.

---

## 2. Vollständiges Verzeichnislayout

```text
faciqor/
├── Makefile                        # Zentrale Orchestrierung (Codegen, Multi-OS-Builds)
├── buf.yaml                        # Protobuf Workspace-Konfiguration (Buf v2)
├── buf.gen.yaml                    # Multi-Language Codegen Definition
│
├── docs/                           # Docs-as-Code (Wissensbasis & Vorgaben)
│   ├── adr/                        # Architecture Decision Records
│   │   ├── 0001-elixir-core.md
│   │   ├── 0002-go-grpc-cli.md
│   │   └── 0003-flutter-offline-sync.md
│   ├── requirements/               # Anforderungskataloge (FA-01 bis FA-06, NFA-01 bis NFA-04)
│   ├── compliance/                 # BetrKV-, GEFMA- und GoBD-Spezifikationen
│   └── architecture_and_projectfolder_layout.md # DIESES DOKUMENT
│
├── design/                         # UI/UX DESIGN SYSTEM & DESIGN TOKENS
│   └── tokens.json                 # Plattformunabhängige Design Tokens (W3C Format: Farben, Typo, Spacing, BetrKV)
│
├── proto/                          # CONTRACTS (Single Source of Truth)
│   └── faciqor/
│       └── v1/
│           ├── common.proto        # Shared Types (UUID, Timestamp, Money/Decimal, GeoPoint)
│           ├── auth.proto          # Token-Exchange, Authentifizierung
│           ├── accounting.proto    # Buchungsjournal, DATEV-Export, BetrKV-Logik
│           └── field.proto         # Vor-Ort-Erfassung, Geofencing, Check-in, Foto-Hashes
│
├── backend/                        # ELIXIR / PHOENIX / ASH STACK
│   ├── mix.exs                     # Elixir Abhängigkeiten
│   ├── mix.lock
│   ├── config/                     # Umgebungskonfigurationen (config.exs, prod.exs, runtime.exs)
│   ├── assets/                     # LiveView Frontend Assets
│   │   └── css/
│   │       └── app.css             # Tailwind v4 / Faciqor Theme Token Integration & ERP Typografie
│   ├── lib/
│   │   ├── faciqor/                # DOMÄNENKERN (Ash Domains, Ecto, Business Rules)
│   │   │   ├── accounts/           # Benutzer, Rollen, Mandanten (RLS)
│   │   │   ├── accounting/         # Buchungsjournal, BetrKV-Regelwerk, DATEV
│   │   │   ├── operations/         # Liegenschaften, Einheiten, GEFMA-Kataloge
│   │   │   └── repo.ex             # Ecto Repo mit RLS Tenant-Scoping
│   │   ├── faciqor_web/            # FACIQOR HUB (Phoenix LiveView für Office-Personal)
│   │   │   ├── endpoint.ex
│   │   │   ├── router.ex           # Web-Routen & Session-Pipelines
│   │   │   ├── components/         # LiveView UI-Komponenten
│   │   │   └── live/               # LiveViews (Dashboard, Disposition, Journal)
│   │   └── faciqor_grpc/           # gRPC SERVER (Schnittstelle für CLI & Mobile)
│   │       ├── endpoint.ex         # gRPC/Cowboy Listener
│   │       ├── interceptors/       # Auth- & Tenant-Injection Interceptor
│   │       ├── generated/          # Aus proto/ via Buf generierter Elixir-Code
│   │       └── services/           # Mapping von gRPC auf Faciqor Domänenaktionen
│   ├── priv/
│   │   ├── repo/migrations/        # PostgreSQL Migrationen (RLS-Policies, Partitionen)
│   │   └── static/                 # Kompilierte Web-Assets
│   └── test/
│
├── cli/                            # GO STANDALONE CLI (faciqor binary)
│   ├── go.mod
│   ├── go.sum
│   ├── cmd/
│   │   └── faciqor/
│   │       └── main.go             # Minimaler Einstiegspunkt
│   ├── internal/
│   │   ├── cmd/                    # Cobra Subcommands (root, accounting, tenant, completion)
│   │   ├── client/                 # gRPC Client Connection-Pool, TLS, Auth-Header
│   │   ├── config/                 # Viper-Konfiguration (~/.config/faciqor/config.yaml)
│   │   └── output/                 # Terminal-Formatierung (Tabellen, Human-Readable vs. --json)
│   └── pkg/
│       └── api/v1/                 # Aus proto/ via Buf generierter Go-Code
│
└── mobile/                         # FLUTTER MOBILE APP (FACIQOR GO & PROOF)
    ├── pubspec.yaml
    ├── android/                    # Native Android Hülle (WorkManager, Background GPS)
    ├── ios/                        # Native iOS Hülle (Background Tasks, CoreLocation)
    ├── lib/
    │   ├── main.dart               # App Einstiegspunkt
    │   └── src/
    │       ├── core/               # Konfiguration, DI, Hilfsklassen
    │       ├── database/           # Drift / SQLite (Lokaler Offline-Speicher)
    │       ├── sync/               # Outbox-Pattern & Background Sync Engine
    │       ├── proof/              # GPS-Geofencing, EXIF-Metadaten & SHA-256 Hash
    │       └── ui/                 # Erfassungsmasken nach GEFMA 480/444 & BetrKV
    └── pkg/
        └── api/v1/                 # Aus proto/ via Buf generierter Dart-gRPC-Code
```

---

## 3. Verantwortlichkeiten der Subsysteme

| Modul / Ordner | Produktname | Primäre Technologie | Rolle im Gesamtsystem |
| :--- | :--- | :--- | :--- |
| `proto/` | - | Protocol Buffers (v3) | Verbindlicher Schnittstellenvertrag für alle APIs. |
| `design/` | - | W3C Design Tokens JSON | Zentrale Single Source of Truth für UI/UX-Tokens (Farben, Typografie, Spacings, BetrKV-Farbsemantik) für Web & Mobile. |
| `backend/lib/faciqor` | - | Elixir (Ash / Ecto) | Transaktionssicherer Domänenkern, GoBD-Journal, RLS-Mandantentrennung. |
| `backend/lib/faciqor_web`| **Faciqor Hub** | Phoenix LiveView | Web-Dashboard für Sachbearbeiter, Verwalter & Eigentümer (In-Process). |
| `backend/assets/css/` | - | Tailwind CSS / CSS Custom Properties | ERP-Styling des Faciqor Hubs basierend auf Design Tokens (`--fq-*`). |
| `backend/lib/faciqor_grpc`| - | Elixir `grpc` | Headless Server-Adapter für externe RPC-Clients. |
| `cli/` | - | Go (Cobra, Viper, gRPC) | Autarke Standalone-CLI für Administration, Scripting und CI/CD. |
| `mobile/` | **Faciqor Go & Proof** | Flutter (Dart, Drift) | Offline-First Feld-App für Dienstleister (Keller/Tiefgaragen, GPS, Fotos). |
| `docs/` | - | Markdown / Docs-as-Code | Architekturvorgaben, juristische Nachweise, ADRs. |

---

## 4. Richtlinien für Schnittstellen & Kommunikation

### 4.1 gRPC Metadaten & Mandanten-Injektion
Jeder RPC-Call aus der Go-CLI oder der Flutter-App muss zwingend folgende Metadaten im HTTP/2-Header mitführen:
* `authorization`: `Bearer <jwt_token>`
* `x-tenant-id`: `<uuid>`

Der Server-Interceptor in `backend/lib/faciqor_grpc/interceptors/tenant_interceptor.ex` validiert das Token und setzt den Mandantenkontext via:
```elixir
Ecto.Adapters.SQL.query!(Faciqor.Repo, "SET LOCAL app.current_tenant_id = $1", [tenant_id])
```

### 4.2 Repräsentation von Währungs- und Dezimalwerten
In `.proto`-Dateien werden Geldbeträge und Messwerte **niemals als Fließkommazahlen (`float` oder `double`)** übertragen:
```protobuf
// KORREKT:
string amount = 1; // z. B. "1250.50" zur verlustfreien Konvertierung in Decimal

// VERBOTEN:
double amount = 1; // Führt zu IEEE-754 Rundungsfehlern in der Finanzbuchhaltung!
```

---

## 5. Offline-Architektur der mobilen App (`mobile/`)

Für Einsätze in Kellerräumen und Tiefgaragen gilt das **Outbox-Pattern**:
1. **Kein direkter Remote-Call bei Aktionen:** Speicherprozesse schreiben die Daten transaktional in die lokale SQLite-Datenbank (`Drift`). Status: `PENDING`.
2. **Foto-Handling:** Fotos werden lokal komprimiert, der SHA-256-Hash berechnet und mit EXIF-Metadaten verknüpft. Bilder werden **nicht** durch den gRPC-Server geschleift, sondern via Pre-Signed S3-URL direkt hochgeladen.
3. **Background Sync:** Ein nativer OS-Hintergrundprozess (`workmanager` / Headless Dart Isolate) sendet gepufferte Datenpakete bei wiederkehrendem Netzempfang im Batch an `faciqor_grpc`.

---

## 6. UI/UX Design System & Styling-Vorgaben

Die Gestaltung aller Client-Frontends (**Faciqor Hub** in Phoenix LiveView sowie **Faciqor Go & Proof** in Flutter) folgt verbindlich dem plattformunabhängigen Token-System:

### 6.1 Design Tokens als UI Single Source of Truth (`design/tokens.json`)
* Sämtliche Farbwerte, Typografie-Definitionen, Abstände (`spacing`), Radien und Klickflächenhöhen (`controlHeight`) sind in [tokens.json](file:///S:/src/faciqor/design/tokens.json) nach der W3C Design Tokens Community Group Spezifikation standardisiert.
* Änderungen am Farbschema oder den visuellen Tokens müssen primär in `design/tokens.json` erfolgen und anschließend in die Client-Stylesheets bzw. Theme-Definitionen übertragen werden.

### 6.2 Faciqor Hub Web Styling (`backend/assets/css/app.css`)
* **Token-Mapping & Tailwind CSS:** Die Tokens werden im CSS Root-Scope als CSS Custom Properties (`--fq-*`) definiert.
* **Exklusive BetrKV-Farbsemantik:** Zur Vermeidung von Fehlbuchungen und Fehleinschätzungen sind BetrKV-Statusfarben strikt reserviert:
  * Umlagefähige Betriebskosten: `--fq-betrkv-allocatable-*` (Grüntöne)
  * Nicht umlagefähige Instandhaltung: `--fq-betrkv-maintenance-*` (Orangetöne)
  * Verwaltungskosten: `--fq-betrkv-admin-*` (Indigotöne)
* **Desktop-First ERP Ergonomie:** Standard-Schriftgröße 14px (`0.875rem`) auf `Inter` für hohe Informationsdichte in Tabellen und Masken.
* **Numerische Präzision:** Geldbeträge, Zeitstempel, Zählerstände und kryptografische Hashes (`.fq-numeric`, `.fq-mono`, `table td[data-type="currency"]`, etc.) verwenden verpflichtend `JetBrains Mono` mit `font-variant-numeric: tabular-nums` für vertikale Lesbarkeit.
* **GoBD-konforme Darstellung:** Festgeschriebene Felder (`input[readonly]`, `textarea[readonly]`) werden visuell eindeutig mit gedämpfter Hintergrundfarbe (`--fq-color-bg-muted`) und Default-Cursor als unveränderlich signalisiert.
* **Touch- & Desktop-Targets:** Berücksichtigung der Klickhöhen (`desktopSm`: 28px, `desktopMd`: 36px für LiveView-Web, `touchMd`: 44px, `touchLg`: 56px für Flutter/Touch-Erfassung).

---

## 7. Zentrale Befehle (Makefile)

Entwickler und automatisierte Agenten nutzen primär die vordefinierten Make-Targets:

```bash
# Schnittstellencode für alle Sprachen generieren (Elixir, Go, Dart)
make proto

# Go CLI für lokales Betriebssystem bauen
make build-cli

# Go CLI statisch für FreeBSD Jails kompilieren
make build-cli-freebsd

# Elixir Backend starten (Phoenix LiveView + gRPC Server)
make dev-backend

# Flutter Code-Generierung und Drift-Tabellen aktualisieren
make codegen-mobile

# Alle Tests projektübergreifend ausführen
make test-all
```

---

## 8. Regeln für KI-Entwicklungsagenten & Entwickler

1. **Keine Kreuz-Imports:** Code aus `cli/` darf niemals versuchen, Code aus `backend/` zu importieren (und umgekehrt). Die einzige Brücke ist `proto/`.
2. **Schema-Migrationen zentralisieren:** Datenbank-Migrationen existieren **ausschließlich** in `backend/priv/repo/migrations/`.
3. **Große Binärdateien vermeiden:** Design-Assets, Raw-Mockups oder Beispiel-Videos gehören nicht in das Git-Repository, sondern werden extern verlinkt (Figma, S3).
4. **Docs-Synchronität:** Wenn eine Domänenaktion geändert wird (z. B. Hinzufügen eines BetrKV-Feldes), muss in demselben Commit die entsprechende `.proto`-Datei und das Dokument in `docs/` aktualisiert werden.