# Faciqor – UI/UX Design-Prinzipien & Layout-Architektur

> **Verbindliche Referenz für Entwickler und KI-Coding-Agenten**  
> **Geltungsbereich:** Faciqor Hub (`backend/lib/faciqor_web/`) & Design-Tokens (`design/tokens.json`, `backend/assets/css/app.css`)  
> **Leitbild:** Strukturierte Informationsarchitektur nach dem Vorbild von **GitHub.com**, kombiniert mit den bestehenden Faciqor-Farb-, Typografie- und Compliance-Tokens (GoBD / BetrKV).

---

## 1. Grundprinzipien

1. **GitHub-inspirierte Informationsarchitektur & Layout-Ordnung:**
   Die Anordnung von Navigation, Kontext-Headern, Listen, Formularen und Einstellungsseiten orientiert sich an den bewährten Layout-Mustern von **GitHub.com** (zweistufiger App-Header mit kontextueller Underline-Subnavigation, 2-Spalten-Splits, gebündelte Box-Container mit Kopf-/Fußzeile, vertikale Einstellungs-Sidebars und strukturierte Danger-Zones).
2. **Strikte Token-Treue (`--fq-*`):**
   Alle Oberflächen-, Rahmen-, Text- und Statusfarben beziehen sich ausschließlich auf [`design/tokens.json`](../design/tokens.json) und [`backend/assets/css/app.css`](../backend/assets/css/app.css). Es werden keine abweichenden Fremdfarbpaletten eingeführt.
3. **Desktop-First ERP-Informationsdichte:**
   Die Basisschriftgröße beträgt `14px` (`0.875rem`, `text-sm`) in `Inter`. Bedienelemente (Buttons, Inputs, Selects) nutzen eine Höhe von `36px` auf Desktop-Bildschirmen (`lg:h-9`) und `44px` auf Touch-Geräten (`h-11`).
4. **Numerische Präzision & Tabular Nums:**
   Alle BusinessKeys, Handles (`@handle`), Geldbeträge, Koordinaten, Zählerstände, Zeitstempel und SHA-256-Hashes müssen zwingend in Monospace (`fq-mono tabular-nums`, `JetBrains Mono`) gesetzt werden.
5. **GoBD-Readonly statt Disabled:**
   Unveränderliche oder durch Rollenberechtigungen (`member` / `guest`) geschützte Datenfelder verwenden `<.input readonly={true}>` (voller Textkontrast `#0F172A`, gedämpfter Hintergrund `#F1F5F9`, Schloss-Indikator `Schreibgeschützt`). Das Attribut `disabled` ist ausschließlich für nicht ausführbare Buttons oder native `<select>`-Elemente reserviert.

---

## 2. Globale App-Shell & Zweistufiger Header (`FaciqorWeb.Layouts.app`)

Der Anwendungsrahmen in [`layouts.ex`](../backend/lib/faciqor_web/components/layouts.ex) gliedert sich analog zu GitHub.com in zwei horizontale Ebenen:

### 2.1 Ebene 1: Globaler Top-Header (`h-14`)
* **Links (Kontext-Pfad & Mandanten-Switcher):**
  * Kompaktes Marken-Badge (`FQ`) + `Faciqor Hub`-Link (`/dashboard`).
  * Kontext-Trenner `/` gefolgt vom interaktiven **Mandanten-Switcher** (`#tenant-switcher` als `<details>`-Dropdown).
  * Zeigt Logo/Initialen, `@handle` und Rollen-Badge (`<.status_badge>`) der aktiven Organisation sowie einen Schnellwechsel zwischen allen verfügbaren Mandanten (`@user_orgs`) und den Direktlink `+ Neue Organisation gründen` (`/orgs/new`).
* **Rechts (Globale Schnellaktionen & Benutzermenü):**
  * Kontextueller `+ Objekt`-Schnellbutton (`/orgs/:handle/facilities/new`), sobald eine Organisation aktiv ist.
  * Benutzerprofil-Link (`/settings/profile`) mit Avatar (`header img[alt='Avatar']`) bzw. Initialen und Anzeigenamen.
  * Abmelde-Button (`#header-sign-out-btn`).

### 2.2 Ebene 2: Kontextuelle Underline-Subnavigation (`#context-subnav`)
* Unterhalb des Top-Headers verläuft eine flache horizontale Tab-Leiste (`bg-[var(--fq-color-bg-muted)]/60 border-t`) für den direkten Wechsel zwischen den Hauptbereichen:
  * **Übersicht** (`/dashboard`)
  * **Objekte & Liegenschaften** (`/orgs/:handle/facilities`) inkl. `@handle`-Pill
  * **Mandanten-Einstellungen** (`/orgs/:handle/settings`)
  * **Benutzerprofil & CLI** (`/settings/profile`)

### 2.3 Hauptcontainer-Raster
* Der `<main>`-Container nutzt `max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6`, um mehrspaltige Desktop-Layouts (12-Spalten-CSS-Grid) ohne horizontales Quetschen darzustellen.

---

## 3. Zentrale Layout-Komponenten (`FaciqorWeb.CoreComponents`)

Neben den Basis-Controls (`<.button>`, `<.input>`, `<.betrkv_badge>`, `<.status_badge>`, `<.proof_badge>`) stellt [`core_components.ex`](../backend/lib/faciqor_web/components/core_components.ex) folgende GitHub-inspirierte Strukturkomponenten bereit:

| Komponente | Zweck & Aufbau |
| :--- | :--- |
| **`<.gh_subhead>`** | Sektions- oder Seitenkopf mit unterer Trennlinie (`pb-3 mb-4 border-b`), Titel (`:title`), optionaler Beschreibung (`:description`) und rechtsbündigen Aktions-Buttons (`:actions`). |
| **`<.gh_box>`** | Umrandeter Inhalts-Container (`rounded-lg border bg-[var(--fq-color-bg-surface)]`) mit optionaler abgesetzter Kopfzeile (`:header`, `:header_actions` auf `--fq-color-bg-muted`), Hauptinhalt und optionaler Fußzeile (`:footer`). |
| **`<.gh_danger_zone>`** | Rot umrandeter Container (`border-[var(--fq-status-danger)] divide-y`) für kritische/revisionsrelevante Aktionen (z. B. 60-Tage-Soft-Delete, Storno), bei dem Beschreibung links und Aktionsbutton rechts angeordnet sind. |
| **`<.table>` mit `:header_bar`** | Hochdichte ERP-Datentabelle mit optionalem `:header_bar`-Slot für eine GitHub-typische Listen-Kopfzeile (z. B. Statuszähler `Aktiv` / `Archiviert` und Gesamtanzahl). |

---

## 4. Seiten-Archetypen (Page Layouts)

### 4.1 Dashboard (`DashboardLive` – 2-Spalten-Split)
* **Raster:** `grid-cols-1 lg:grid-cols-12 gap-6 items-start`
* **Linke Spalte (`lg:col-span-4 xl:col-span-3`, `#dashboard-sidebar`):**
  * Kompakte Benutzer-Visitenkarte (Avatar, Name, `@handle`, Verifizierungs-Status, Direktlink zu `/settings/profile`).
  * `<.gh_box>` **Mandanten-Schnellliste** mit Zähler-Badge, `+ Neu`-Button und direktem Sprung in Objekte oder Einstellungen jeder Organisation.
* **Rechte Hauptspalte (`lg:col-span-8 xl:col-span-9`):**
  * `<.gh_subhead>` mit Hauptaktion (`+ Neue Organisation gründen`).
  * Bei neuen Konten ohne Mandant: 2-spaltiger Onboarding-Empty-State (`#onboarding-empty-state`) in `<.gh_box>`-Karten.
  * Bei vorhandenen Mandanten: Vollständige Mandanten-Tabelle (`#organizations-table`) mit `:header_bar`.

### 4.2 Listen- & Repository-Ansichten (`FacilityIndexLive`)
* **Kopfbereich:** `<.gh_subhead>` mit Seitentitel, `@org.handle`, Rollen-Badge und primären/sekundären Aktionen (`Nummernkreise & Geo-Provider`, `+ Neues Objekt anlegen`).
* **Filter- & Suchleiste (`#facilities-filter-form`):** Kompakte horizontale Toolbar mit Suchfeld links und Filter-Toggles (z. B. `Archivierte Objekte einblenden`) rechts.
* **Boxed Table (`#facilities-table`):** nutzt den `:header_bar`-Slot zur Anzeige von Live-Statuszählern (`Aktiv` mit grünem Punkt, `Archiviert` mit grauem Punkt, Gesamtanzahl).

### 4.3 Editor- & Detail-Ansichten (`FacilityFormLive` – 2-Spalten-Arbeitsbereich)
* **Raster:** `grid-cols-1 lg:grid-cols-12 gap-6 items-start`
* **Linke Hauptspalte (`lg:col-span-8`):**
  * **Box 1:** Adress-Suche, Hausnummern-Bereichsexpansion, Mehrfachtreffer-Auswahl (`#disambiguation-panel`) und Teiladressen-Tabelle (`#facility-addresses-table`).
  * **Box 2:** PostGIS-Geofence-Kartenansicht (`#facility-map-wrapper` mit `phx-update="ignore"`) und integriertem Radius-Schieberegler im `:header_actions`-Slot der `<.gh_box>`.
* **Rechte Sticky-Metadaten-Sidebar (`lg:col-span-4 lg:sticky lg:top-6`):**
  * `<.gh_box>` für **Objekt-Identität & Vorschau**: Schreibgeschützter `BusinessKey` (`#facility-business-key`), automatisch generierter `Objekt-Titel` (`#facility-title-preview`), Kennzahlen-Zusammenfassung (Anzahl Teiladressen, Polygon-Eckpunkte, Kartenanbieter) sowie primärer Speichern- (`#save-facility-btn`) und Abbrechen-Button im `:footer`-Slot.

### 4.4 Einstellungs-Seiten (`OrgSettingsLive` & `ProfileSettingsLive` – Vertikale Sidebar-Navigation)
Um lange, unübersichtliche Endlos-Formulare zu vermeiden, folgen alle Einstellungs-Seiten dem **GitHub Settings Layout**:
* **Kontext-Kopfzeile (`pb-4 border-b`):**
  * Zeigt das Organisationslogo bzw. den Benutzer-Avatar (`w-12 h-12`), den Namen/`@handle`, das Rollen-Badge sowie einen Zurück-/Kontext-Button (`Objekte & Liegenschaften verwalten` bzw. `Zum Dashboard`).
* **2-Spalten-Body (`grid-cols-1 lg:grid-cols-12 gap-8 items-start`):**
  * **Linke vertikale Navigations-Sidebar (`lg:col-span-3`):**
    * Gegliedert durch dezente Gruppen-Überschriften (`text-[11px] font-semibold uppercase tracking-wider`).
    * Interaktive Buttons (`phx-click="switch_tab"`), wobei der aktive Tab durch `bg-[var(--fq-color-bg-muted)] font-semibold border-l-2 border-[var(--fq-color-primary)]` hervorgehoben wird.
  * **Rechter Inhaltsbereich (`lg:col-span-9`):**
    * Zeigt die zum gewählten Tab gehörigen `<.gh_subhead>`- und `<.gh_box>`-Sektionen.
    * Inaktive Tab-Container werden per CSS-Klasse `hidden` ausgeblendet, sodass der Wechsel verzögerungsfrei erfolgt, nicht gespeicherte Formulareingaben erhalten bleiben und LiveView-Tests jederzeit auf alle Formular-IDs zugreifen können.
    * Destruktive Aktionen am Seitenende bzw. im Gefahrenzonen-Tab nutzen `<.gh_danger_zone>`.

---

## 5. Farbsemantik & DOM-Isolations-Regeln

1. **Exklusive BetrKV-Farben:**
   Die CSS-Variablen `--fq-betrkv-allocatable-*` (Grün), `--fq-betrkv-maintenance-*` (Orange) und `--fq-betrkv-admin-*` (Indigo) dürfen ausschließlich in `<.betrkv_badge>` zur rechtlichen Klassifizierung nach Betriebskostenverordnung verwendet werden.
2. **Client-Side JS Hooks (`phx-update="ignore"`):**
   Dynamische Canvas-/Karten-Container (`#facility-map-wrapper`, `#avatar-crop-preview-wrapper`, `#logo-crop-preview-wrapper`) müssen zwingend `phx-update="ignore"` und eine explizite feste Höhe (`h-80`, `h-96`) besitzen, damit Morphdom bei LiveView-Updates weder die CropperJS- noch die Leaflet-Instanz verwirft.
