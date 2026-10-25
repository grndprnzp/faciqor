# Faciqor – Developer Guide & Monorepo Setup

Willkommen im **Faciqor** Monorepo. Faciqor ist eine mandantenfähige ERP- und Leistungsnachweis-Plattform für Immobilienverwaltung, Bestandshalter und Objektbetreuung (strikte Trennung nach BetrKV, GoBD-konforme Buchhaltung und Offline-First Vor-Ort-Erfassung).

Dieses Dokument führt Entwickler Schritt für Schritt durch das lokale Setup unter **Linux** und **Windows** (unter der Voraussetzung, dass **Docker** bzw. Podman oder eine vergleichbare Container-/Jail-Lösung bereits installiert ist).

---

## 1. Architektur- & Projektübersicht

Das Monorepo ist nach dem **Contract-First-Prinzip** aufgebaut. Es gibt keine direkten Code-Abhängigkeiten zwischen den Programmiersprachen – die einzige Brücke bildet `proto/`.

| Verzeichnis | Komponente | Technologie-Stack | Standard-Port |
| :--- | :--- | :--- | :--- |
| [`proto/`](proto/) | **API Contracts** | Protocol Buffers v3 (`buf.build`) | – |
| [`design/`](design/) | **Design System** | W3C Design Tokens (`tokens.json`) | – |
| [`docker/`](docker/) | **Infrastruktur** | PostgreSQL 16 & SeaweedFS (S3 Object Storage) | `5432` (DB), `8333` (S3), `8888` (Filer UI) |
| [`backend/`](backend/) | **Faciqor Core, Hub & gRPC** | Elixir 1.16+, Phoenix LiveView, Ash 3.x, Oban, gRPC | `4000` (Web), `50051` (gRPC) |
| [`cli/`](cli/) | **Standalone CLI (`faciqor`)** | Go 1.22+, Cobra, Viper, gRPC | Verbindet auf `:50051` |
| [`mobile/`](mobile/) | **Faciqor Go & Proof** | Flutter / Dart, Drift (SQLite Outbox) | Verbindet auf `:50051` |
| [`docs/`](docs/) | **Docs-as-Code** | Architektur-, Compliance- & Milestone-Spezifikationen | – |

Weiterführende Details finden sich in:
* [`docs/architecture_and_projectfolder_layout.md`](docs/architecture_and_projectfolder_layout.md) – Verbindliche Monorepo-Architektur & Verzeichnisstruktur
* [`AGENTS.md`](AGENTS.md) – Leitplanken für Entwickler & KI-Coding-Agenten (RLS, Ash-Policies, GoBD)
* [`docs/requirements/001-milrestone.md`](docs/requirements/001-milrestone.md) – Spezifikation Meilenstein 1 (Identity, Profile & Organization Boilerplate)

---

## 2. Voraussetzungen (Plattformübergreifend)

### 2.1 Infrastruktur via Container (PostgreSQL & SeaweedFS S3-Storage)
Für die lokale Entwicklung wird eine laufende **PostgreSQL 16+**-Instanz (mit `citext` und `uuid-ossp`) sowie **SeaweedFS** als S3-kompatibler Object Storage (für Avatare, Firmenlogos und GoBD-konforme Belege/Nachweise) benötigt.

Beide Dienste können bequem über Docker Compose im Verzeichnis [`docker/`](docker/) gestartet werden (identisch auf Linux & Windows):

```bash
# 1. Optionale Anpassung der Ports/Zugangsdaten (Standardwerte funktionieren out-of-the-box):
cp docker/.env.example docker/.env

# 2. Beide Dienste im Hintergrund starten:
docker compose -f docker/compose.yml up -d
```

Nach dem Start stehen folgende Endpunkte zur Verfügung:
* **PostgreSQL 16:** `localhost:5432` (Datenbank `faciqor_dev`, User `postgres`, Passwort `postgres`)
* **SeaweedFS S3 API:** `http://localhost:8333` (S3-Endpunkt für Pre-Signed URLs & Blob-Uploads)
* **SeaweedFS Filer Web-UI:** [http://localhost:8888](http://localhost:8888) (Dateibrowser im Web zum Prüfen hochgeladener Buckets und Blobs)

> **Hinweis für Podman / Standalone / FreeBSD Jails:**  
> Die Dienste können alternativ als Einzelcontainer gestartet werden:
> ```bash
> # PostgreSQL 16:
> docker run -d --name faciqor-postgres -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=faciqor_dev -p 5432:5432 postgres:16-alpine
>
> # SeaweedFS (S3-Gateway + Filer Web-UI):
> docker run -d --name faciqor-storage -p 8333:8333 -p 8888:8888 -v faciqor_seaweedfs_data:/data chrislusf/seaweedfs:latest server -s3 -dir=/data -s3.port=8333 -ip.bind=0.0.0.0
> ```

### 2.2 Benötigte Sprach-Toolchains
Falls nicht komplett im Container entwickelt wird, sollten folgende Werkzeuge installiert sein:
1. **Elixir `~> 1.16` & Erlang/OTP `26+`**
2. **Go `1.22+`**
3. **Buf CLI (`buf`)** – Für Protobuf Linting & Code-Generierung
4. **GNU Make** *(optional auf Windows, siehe Windows-Leitfaden)*

---

## 3. Setup & Workflow unter Linux

### 3.1 Toolchains installieren (falls noch nicht vorhanden)
Auf modernen Linux-Distributionen (Ubuntu/Debian, Fedora, Arch) empfiehlt sich [`mise`](https://mise.jdx.dev/) oder [`asdf`](https://asdf-vm.com/), alternativ die Paketverwaltung:

```bash
# Beispiel via mise (empfohlen für exakte Versionen)
mise use -g erlang@26 elixir@1.16 go@1.22 buf@latest
```

### 3.2 Backend initialisieren & starten
```bash
cd backend

# 1. Elixir-Abhängigkeiten herunterladen
mix deps.get

# 2. Datenbank erstellen und Migrationen (inkl. citext & uuid-ossp) ausführen
mix ecto.setup

# 3. Faciqor Hub (Port 4000) + gRPC-Server (Port 50051) starten
mix phx.server
```

Sobald der Server läuft:
* **Web-UI (Faciqor Hub):** [http://localhost:4000/sign-in](http://localhost:4000/sign-in)
* **gRPC-Endpunkt:** `localhost:50051`

### 3.3 Go-CLI kompilieren & ausführen
In einem zweiten Terminal:

```bash
# Über das zentrale Makefile im Projekt-Root:
make build-cli

# Oder direkt im cli/-Verzeichnis:
cd cli
go build -o ../bin/faciqor ./cmd/faciqor
```

---

## 4. Leitfaden für Windows-Entwickler

Als Windows-Entwickler (mit bereits installiertem **Docker Desktop** oder **Rancher Desktop**) hast du zwei erstklassige Wege, um Faciqor zu entwickeln und auszuführen:

### Option A: Native Entwicklung in PowerShell (ohne WSL-Zwang)

Wenn du direkt unter Windows (PowerShell / Windows Terminal) arbeitest:

#### 1. Zeilenenden (CRLF vs. LF) in Git absichern
Damit Shell-Skripte, Protobuf-Generatoren und Docker-Mounts auf Windows keine Zeilenumbruch-Probleme verursachen, konfiguriere Git im Repository wie folgt:
```powershell
git config core.autocrlf input
```

#### 2. Toolchains via `winget` oder `scoop` installieren
Öffne eine **PowerShell** und installiere Elixir, Go und Buf:
```powershell
# Mit Winget (Windows Bordmittel):
winget install Erlang.ErlangOTP
winget install Elixir.Elixir
winget install GoLang.Go
winget install bufbuild.buf
```
*(Schließe und öffne das PowerShell-Fenster danach neu, damit die `PATH`-Variablen aktiv sind.)*

#### 3. Lokale Infrastruktur in PowerShell starten
Falls die Container aus Abschnitt 2.1 noch nicht laufen:
```powershell
docker compose -f docker\compose.yml up -d
```
*(Alternativ via `docker run`: siehe Einzelbefehle in Abschnitt 2.1)*

#### 4. Backend & CLI in PowerShell starten (ohne `make`)
Da `make` unter Windows standardmäßig nicht vorinstalliert ist, kannst du alle Befehle aus dem [`Makefile`](Makefile) direkt als native PowerShell-Kommandos ausführen:

```powershell
# --- BACKEND STARTEN ---
Set-Location backend
mix local.hex --force
mix local.rebar --force
mix deps.get
mix ecto.create
mix ecto.migrate
mix phx.server
```

In einem zweiten PowerShell-Fenster baust und nutzt du die **Go-CLI** (`faciqor.exe`):
```powershell
# --- GO CLI BAUEN ---
Set-Location cli
go mod tidy
New-Item -ItemType Directory -Force -Path ..\bin | Out-Null
go build -o ..\bin\faciqor.exe .\cmd\faciqor

# --- CLI AUSFÜHREN ---
..\bin\faciqor.exe --help
```

> **Konfigurationspfad unter Windows:**  
> Die Go-CLI nutzt `os.UserConfigDir()`. Unter Windows wird die Datei `config.yaml` automatisch unter `%APPDATA%\faciqor\config.yaml` (z. B. `C:\Users\<Name>\AppData\Roaming\faciqor\config.yaml`) angelegt, unter Linux unter `~/.config/faciqor/config.yaml`.

---

### Option B: Vollständig containerisierte Ausführung (Zero Host-Install)

Wenn du auf deinem Windows-Host **weder Elixir noch Go** lokal installieren möchtest, kannst du Backend, Tests und CLI-Build komplett über Docker-Container ausführen.

#### 1.Eigenes Docker-Netzwerk für DB & Backend anlegen
```powershell
docker network create faciqor-net
docker network connect faciqor-net faciqor-postgres
```

#### 2. Elixir-Backend & Tests im Container ausführen
Aus dem Projekt-Root (`S:\src\faciqor`):
```powershell
docker run --rm -it `
  --network faciqor-net `
  -v "${PWD}/backend:/app" `
  -w /app `
  -p 4000:4000 `
  -p 50051:50051 `
  hexpm/elixir:1.16.2-erlang-26.2.5-alpine-3.19.1 `
  sh -c "apk add --no-cache build-base git && mix local.hex --force && mix local.rebar --force && mix deps.get && mix phx.server"
```
*(Hinweis: Setze in `backend/config/dev.exs` bei reinem Container-Betrieb `hostname: "faciqor-postgres"` und `http: [ip: {0, 0, 0, 0}, port: 4000]`.)*

#### 3. Go-CLI im Container bauen & testen
```powershell
docker run --rm -it `
  -v "${PWD}/cli:/app" `
  -w /app `
  golang:1.22-alpine `
  sh -c "go test -v ./..."
```

---

## 5. Erster End-to-End Durchlauf (Web-UI & Go-CLI)

Sobald das Backend (`mix phx.server`) läuft, kannst du den kompletten Workflow aus Meilenstein 1 testen:

1. **Registrierung im Web (`Faciqor Hub`):**
   * Öffne [http://localhost:4000/register](http://localhost:4000/register).
   * Melde dich per **Magic Link** (Token wird im Terminal-Log von `mix phx.server` ausgegeben) oder per **Passwort** an.
   * Dein `@handle` wird automatisch aus deiner E-Mail-Adresse generiert.
2. **E-Mail-Verifizierung & Personal Access Token (PAT):**
   * Unbestätigte Passwort-Konten haben 14 Tage Kulanzfrist im Web, sind aber für die CLI gesperrt (`PERMISSION_DENIED`).
   * Nach E-Mail-Bestätigung (oder Login via Magic Link) öffne [http://localhost:4000/settings/profile](http://localhost:4000/settings/profile).
   * Erstelle unter **„2. Personal Access Tokens“** ein neues Token (`fq_pat_...`).
3. **Mit der Go-CLI anmelden und Organisation gründen:**
   ```bash
   # 1. Token in lokaler CLI-Konfiguration speichern & Verbindung prüfen
   ./bin/faciqor auth login --token fq_pat_dein_token_hier

   # 2. Eigenes Profil abrufen
   ./bin/faciqor profile show

   # 3. Erste Organisation (Mandant) als Hausverwaltung gründen
   ./bin/faciqor org create --handle meine-hv --focus manager --legal-name "Muster Hausverwaltung GmbH"

   # 4. Organisationen als strukturiertes JSON ausgeben
   ./bin/faciqor org list --json
   ```

---

## 6. Qualitätssicherung & Tests ausführen

Vor jedem Commit oder Pull Request müssen folgende Prüfungen fehlerfrei durchlaufen:

### Backend (Elixir / Ash / LiveView / gRPC)
```bash
cd backend

# Formatierung prüfen
mix format --check-formatted

# Striktes Kompilieren (Warnungen = Fehler)
mix compile --warnings-as-errors

# Gesamte Test-Suite (Ash Policies, 14-Tage-Gate, 60-Tage-Soft-Delete, LiveViews, gRPC)
mix test
```

### Standalone CLI (Go)
```bash
cd cli

# Statische Code-Analyse
go vet ./...

# Unit- & CLI-Workflow-Tests
go test -v ./...
```

### Protobuf Contracts (`proto/`)
Wenn `.proto`-Dateien in [`proto/faciqor/v1/`](proto/faciqor/v1/) angepasst werden:
```bash
buf lint
buf generate
```
