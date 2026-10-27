# AGENTS.md – Vorgaben für KI-Coding-Agenten & Entwickler

> **Geltungsbereich:** Gesamtes Faciqor Monorepo (`backend/`, `cli/`, `mobile/`, `proto/`, `docs/`)  
> **Ziel:** Gewährleistung von Datenintegrität, Mandantensicherheit, Typgenauigkeit und sauberer Architektur bei automatisierten und manuellen Code-Modifikationen.

---

## 1. Grundsätzliches Agenten-Verhalten

1. **Keine unaufgeforderten Architektursprünge:** Halte dich strikt an das in `docs/project_layout_reference.md` definierte Monorepo-Layout.
2. **Contract-First-Disziplin:** Ändere niemals API-Typen oder Schnittstellen im Backend (`backend/`) oder in Clients (`cli/`, `mobile/`), ohne zuvor den Vertrag in `proto/faciqor/v1/` angepasst und via `make proto` neu kompiliert zu haben.
3. **Docs-Synchronität:** Wenn Domänenlogik, Entitäten oder Compliance-Regeln geändert werden, aktualisiere die entsprechenden Dokumente in `docs/` im selben Arbeitsgang.
4. **Keine Kreuz-Imports:** Erzeuge niemals Import-Verbindungen über Sprachgrenzen hinweg. Code in `cli/` (Go) oder `mobile/` (Dart) darf nichts aus `backend/` (Elixir) referenzieren. Die einzige Brücke ist `proto/`.

---

## 2. PostgreSQL & Row-Level Security (RLS)

Alle agentenbasierten DB-Eingriffe und Migrationen müssen folgenden Prinzipien genügen:

### 2.1 Strikte Mandanten-Isolation & PgBouncer-Sicherheit
Da Faciqor im Betrieb PgBouncer mit Transaction-Pooling einsetzt, wird dieselbe Datenbankverbindung nach jedem Commit an andere Anfragen weitergereicht.

* **VERBOTEN:** `SET app.current_tenant_id = '...'` (Leckt in fremde Transaktionen!)
* **PFLICHT:** `SET LOCAL app.current_tenant_id = $1` innerhalb einer transaktionalen Pipeline.
* **PFLICHT:** Jede multi-tenant-fähige Tabelle besitzt die Spalte `tenant_id UUID NOT NULL REFERENCES tenants(id)`.
* **PFLICHT:** RLS muss mit `FORCE` aktiviert werden:
  ```sql
  ALTER TABLE <table_name> ENABLE ROW LEVEL SECURITY;
  ALTER TABLE <table_name> FORCE ROW LEVEL SECURITY;
  ```
* Die Standard-Policy für Applikationsnutzer (`erp_app_user` mit `NOBYPASSRLS`):
  ```sql
  CREATE POLICY tenant_isolation_policy ON <table_name>
      AS RESTRICTIVE
      FOR ALL
      TO erp_app_user
      USING (tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::UUID)
      WITH CHECK (tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::UUID);
  ```

### 2.2 Partition Pruning & Query-Optimierung
* Auch wenn RLS die Datensätze filtert, muss der Query-Optimizer von PostgreSQL statisches Partition Pruning anwenden können.
* **Regel:** Bei expliziten SQL-Abfragen oder partitionierten Indizes muss `tenant_id = $1` immer explizit im Query-Filter stehen, damit nicht alle physischen Hash-Partitionen gescannt werden.

---

## 3. Ash-Framework (v3.x) & Domänenkern

Das Backend nutzt das Ash Framework für die Domänenlogik. Direkte Umgehungen von Ash über nackte Ecto-Queries sind in Anwendungs-Code untersagt.

### 3.1 Ressourcen-Deklaration & Multi-Tenancy
Jede mandantenbezogene Ressource in `backend/lib/faciqor/` muss Multi-Tenancy deklarieren:

```elixir
defmodule Faciqor.Accounting.JournalEntry do
  use Ash.Resource,
    otp_app: :faciqor,
    domain: Faciqor.Accounting,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "journal_entries"
    repo Faciqor.Repo
  end

  multitenancy do
    strategy :attribute
    attribute :tenant_id
    global? false # VERBIETET Anfragen ohne explizit übergebenen Mandanten!
  end

  # ...
end
```

### 3.2 Aktionen & Changesets
* **Keine ungeschützten Defaults:** Nutze niemals unreflektiert generische CRUD-Aktionen. Jede Statusänderung (z. B. `book`, `cancel`, `verify_proof`) ist eine explizite Ash-Action.
* **Actor & Tenant weiterreichen:** Beim Aufruf von Domain-Funktionen müssen `actor:` (aktueller Benutzer) und `tenant:` (aktuelle Tenant-UUID) immer zwingend übergeben werden:
  ```elixir
  # KORREKT
  Faciqor.Accounting.post_journal_entry(params, actor: current_user, tenant: current_tenant.id)

  # VERBOTEN
  Faciqor.Accounting.post_journal_entry(params)
  ```

### 3.3 Ash-Policies
* Verwende `Ash.Policy.Authorizer` für feingranulare Autorisierung.
* Autorisierungsregeln gehören in die Ressource (`policies do ... end`), nicht verstreut in Phoenix LiveView Mounts oder gRPC-Services.

### 3.4 Explizite Attribut-Akzeptanz in Aktionen
* Benutzerdefinierte Ash-Aktionen (`create :action_name` / `update :action_name`) akzeptieren standardmäßig keine Attribute.
* **PFLICHT:** Alle Attribute, die über Action-Parameter persistiert werden müssen (z. B. technische Metadaten wie `:width`, `:height`), müssen zwingend in `accept [...]` deklariert sein. Ash verwirft nicht deklarierte Felder stillschweigend.

---

## 4. Elixir & Phoenix LiveView (Faciqor Hub)

### 4.1 Trennung von Web und Core
* `backend/lib/faciqor/` enthält **ausschließlich reine Domänenlogik**. Keine Abhängigkeiten zu Plug, Phoenix, LiveView oder HTTP.
* `backend/lib/faciqor_web/` ist die Präsentationsschicht (LiveView, HTML, Router, UI-Komponenten).
* `backend/lib/faciqor_grpc/` ist der gRPC-Endpunkt-Adapter, der gRPC-Requests auf Ash-Aktionen mappt.

### 4.2 Desktop-First UI & Design-System (GitHub-Inspirierte Layout-Architektur)
* Halte dich bei allen Templates an die Design-Vorgaben und Seiten-Archetypen (2-stufiger Header mit Underline-Subnav, 2-Spalten-Dashboard/Editor, vertikale Settings-Sidebars) in `docs/ui_design_guidelines.md` und die Token-Definitionen in `backend/assets/css/app.css`.
* Verwende zentrale Komponenten aus `FaciqorWeb.CoreComponents` (`<.button>`, `<.input>`, `<.table>`, `<.gh_subhead>`, `<.gh_box>`, `<.gh_danger_zone>`, `<.betrkv_badge>`, `<.proof_badge>`).
* **Desktop-First Informationsdichte:** Desktop-Controls (`≥ 1024px`) haben eine Höhe von 36px (`lg:h-9`), auf Touch-Screens 44px (`h-11`).
* **Zahlen & Geldbeträge:** Immer in Monospace mit Tabellenziffern formatieren (`fq-mono tabular-nums`).

### 4.3 Echtzeit-Updates via BEAM PubSub
* Wenn gRPC-Dienste (durch Vor-Ort-Einsätze von `mobile/`) oder CLI-Befehle Daten manipulieren, muss ein Event über `Phoenix.PubSub` gesendet werden:
  ```elixir
  Phoenix.PubSub.broadcast(Faciqor.PubSub, "tenant:#{tenant_id}:operations", {:work_order_completed, order_id})
  ```
* LiveViews abonnieren diese Topics im `mount/3` und aktualisieren sich ohne Page Reload.

### 4.4 Client-Side JS Hooks & DOM-Isolation (Cropper, Charts, Maps)
Wenn JavaScript-Bibliotheken (z. B. CropperJS, Leaflet, Chart.js) das DOM dynamisch manipulieren:
* **PFLICHT:** Der Wrapper-Container muss `phx-update="ignore"` tragen, damit LiveView/Morphdom bei Rerenders die dynamischen Knoten nicht verwirft oder zerstört.
* **PFLICHT:** Container für dynamische Medien/Canvases müssen eine feste Mindesthöhe (z. B. `h-80`) haben, um Höhen-Kollaps (`0px`) während der Initialisierung zu verhindern.
* **PFLICHT:** Bildquellen (`previewImg.src = dataUrl`) decodieren asynchron. Die Initialisierung von Canvas/Cropper-Instanzen darf erst im `previewImg.onload`-Callback erfolgen.
* **PFLICHT:** Modale Aktionsbuttons müssen per Event-Delegation (`document.addEventListener`) angebunden und im `destroyed()`-Hook sauber deregistriert werden, um Event-Verluste bei Morphdom-Patches zu verhindern.

---

## 5. Finanz-, BetrKV- und GoBD-Compliance

### 5.1 Absolute Dezimalpräzision (Keine Floats!)
* **VERBOTEN:** Die Verwendung von nativen `float`-Datentypen in Elixir, Go oder Protobuf für Währungen, Quadratmeter oder Zählerstände.
* **PFLICHT (Elixir):** `Decimal`-Modul (`Decimal.new("1250.50")`).
* **PFLICHT (PostgreSQL):** `NUMERIC(12, 2)` oder `NUMERIC(14, 4)`.
* **PFLICHT (Protobuf):** `string amount = 1;`.

### 5.2 GoBD: Append-Only Ledger & Revisionssicherheit
* Tabellen wie `journal_entries`, `audit_logs` und `proof_records` sind unveränderlich.
* **VERBOTEN:** `UPDATE` oder `DELETE` auf gebuchte Journaleinträge.
* **PFLICHT:** Stornierungen erfolgen ausschließlich durch Gegenbuchungen (`storno_entry_id` mit Referenz auf den Ursprungssatz).
* UI-Inputs für festgeschriebene Buchungen nutzen `<.input readonly={true}>` (voller Textkontrast, kopierbar, Schloss-Icon), **nicht** `disabled` (welches für inaktive Buttons reserviert ist).

### 5.3 BetrKV-Klassifizierungspflicht
Jede handwerkliche Tätigkeit muss zwingend bei der Erfassung in eine der drei Rechtskategorien einsortiert werden:
1. `:allocatable` (§ 2 Nr. 14 BetrKV – Umlagefähig)
2. `:maintenance` (§ 1 Abs. 2 BetrKV – Nicht umlagefähige Instandsetzung/Substanzerhalt)
3. `:admin` (§ 1 Abs. 2 Nr. 1 BetrKV – Verwaltung/Regie)

---

## 6. Arbeitsabläufe für Agenten bei Code-Änderungen

Wenn du als Agent ein Feature oder einen Fix implementierst, folge strikt dieser Reihenfolge:

```text
1. Spezifikation / Vertrag prüfen  (proto/ & docs/)
         │
         ▼
2. Bei Schema-/API-Änderung:       .proto anpassen ──> `make proto` ausführen
         │
         ▼
3. Datenmodell & RLS:              Migration in backend/priv/repo/migrations/
         │
         ▼
4. Domänenlogik:                   Ash Resource / Domain in backend/lib/faciqor/
         │
         ▼
5. Schnittstellen implementieren:  - gRPC Service in backend/lib/faciqor_grpc/
                                   - LiveView in backend/lib/faciqor_web/
                                   - Cobra Command in cli/
                                   - Flutter Screen/Store in mobile/
         │
         ▼
6. Verifikation:                   Tests ausführen (`mix test`, `go test ./...`)
```

---

## 7. Verbotene Praktiken (Anti-Patterns)

* ❌ **Keine Raw-Ecto-Bypässe:** Schreibe niemals `Repo.all(from j in "journal_entries")` unter Umgehung der Ash-Domain und RLS-Policy.
* ❌ **Keine Client-Trust-Tenant-IDs:** Akzeptiere niemals eine vom Client im Request-Body übergebene `tenant_id` ohne vorherige Validierung gegen den JWT-Token-Claim.
* ❌ **Keine Frontend-Löschbuttons für Finanzdaten:** Benenne destruktive Aktionen niemals „Löschen“, sondern „Stornieren“ bzw. „Abnahme verweigern“.
* ❌ **Keine riesigen Binärdateien im Git & kein Durchschleifen von Blobs:** Bilder, Mockups und Belege gehören in den S3-kompatiblen Object Storage. Clients laden via Pre-Signed S3-URLs direkt hoch; im Backend und in der DB werden ausschließlich SHA-256-Hashes und Storage-Keys verarbeitet.
* ❌ **Kein MinIO / keine Copyleft-Storage-Tools:** Verwende niemals MinIO (AGPLv3-Lizenzrisiko). Für lokale Entwicklung und On-Premise/FreeBSD-Installationen wird ausschließlich das permissiv lizenzierte SeaweedFS (Apache 2.0) eingesetzt, in der Cloud standardisierte S3-Dienste (Cloudflare R2, Hetzner, AWS S3).
* ❌ **Keine uninitialisierten Dev-Buckets:** S3-kompatible Speicher im lokalen Dev-Betrieb (SeaweedFS) starten mit leerem Dateisystem. Das Backend muss bei Applikationsstart (`Storage.ensure_buckets/0`) zwingend idempotent prüfen, ob die Pflicht-Buckets (`faciqor-public`, `faciqor-vault`) existieren, und diese bei Bedarf automatisch anlegen, um `403 AccessDenied`/`404 NoSuchBucket`-Fehler bei Uploads zu verhindern.