# Requirement-Spezifikation: Meilenstein 1 – Identity, Profile & Organization Boilerplate

- **Dokument-ID:** REQ-M1-BOILERPLATE
- **Version:** 1.0.0
- **Status:** Freigegeben für Implementierung (Coding Agents & Developers)
- **Betroffene Systemkomponenten:** `proto/`, `backend/` (`faciqor`, `faciqor_web`, `faciqor_grpc`), `cli/`

---

## 1. Zielsetzung & Scope

Meilenstein 1 legt das technische und fachliche Fundament der **Faciqor**-Plattform[cite: 10]. Ziel ist ein reibungsloser Registrierungs- und Authentifizierungs-Workflow im Web (`faciqor_web`)[cite: 3], die Verwaltung des eigenen Benutzerprofils sowie die Gründung und Verwaltung von Organisationen (Mandanten) in einer M:N-Beziehungsstruktur. Alle Kernfunktionen nach dem Login müssen von Tag 1 an gleichwertig über die Web-UI (Phoenix LiveView) und die unabhängige Standalone-CLI (Go via gRPC) bedienbar sein[cite: 3].

### 1.1 In Scope (Meilenstein 1)
- Registrierung und Anmeldung via E-Mail/Passwort, Magic Link und Google OAuth2 auf Basis von `AshAuthentication`[cite: 9].
- Automatisches Account-Linking über die verifizierte E-Mail-Adresse.
- Benutzerprofil-Verwaltung (Fokus auf eindeutiges `@handle` und E-Mail-Adresse).
- 14-tägige Kulanzfrist (Grace Period) für unbestätigte E-Mail-Adressen im Web bei gleichzeitiger Sperrung aller API-/CLI-Zugriffe und ausgehender Systemkommunikation.
- M:N-Organisationsmodell (`:owner`, `:member`, `:guest`) inklusive Pflichtauswahl des Tätigkeitsschwerpunkts (`:property_owner`, `:property_manager`, `:service_provider`)[cite: 1, 6].
- 60-tägiger Soft-Delete-Lebenszyklus für Benutzerkonten inklusive automatischer Kaskadierung auf Organisationen, bei denen der Nutzer der letzte verbliebene `:owner` ist.
- Vollständige gRPC-Schnittstelle (`faciqor_grpc`) und Go-CLI-Befehle (`cli/`)[cite: 3].

### 1.2 Out of Scope (Folgemeilensteine)
- Einladungs-Workflows für externe Benutzer in Organisationen (Rollen `:member` und `:guest` werden im Datenmodell angelegt, das aktive Einladen folgt in Meilenstein 2).
- Fachmodule wie Buchungsjournal (`Faciqor Clear`), Liegenschaftsverwaltung oder mobile Offline-Erfassung (`Faciqor Go`)[cite: 3, 10].

---

## 2. Architektur- & Technologie-Vorgaben

1. **Backend-Framework:** Elixir, Phoenix LiveView (`faciqor_web`), Ash Framework 3.x (`ash`, `ash_postgres`, `ash_authentication`, `ash_authentication_phoenix`, `ash_oban`)[cite: 3, 9].
2. **Datenbank:** PostgreSQL mit `citext`-Extension für Case-Insensitive Strings (E-Mail, Handles) und Vorbereitung für Row-Level Security (RLS)[cite: 3].
3. **CLI & Schnittstelle:** Contract-First über Protocol Buffers (`proto/faciqor/v1/identity.proto`), `buf.build` Code-Generierung, Elixir gRPC-Server (`faciqor_grpc`) und Go-CLI (`cli/`)[cite: 3].
4. **UI/UX:** Strikte Einhaltung der Faciqor UI & Design System Guidelines (`docs/ui_design_guidelines.md`, `design/tokens.json`, CSS-Variablen `--fq-*`, Desktop-First mit Graceful Degradation für Mobile)[cite: 12].

---

## 3. Domänenmodell & Ash-Ressourcen (`Faciqor.Accounts`)

Alle Ressourcen dieses Meilensteins befinden sich in der Ash-Domain `Faciqor.Accounts` (`backend/lib/faciqor/accounts/`)[cite: 3]. Da `User` und `Organization` die Mandantenstruktur selbst definieren, sind diese Tabellen global, aber strikt über `Ash.Policy.Authorizer` abgesichert[cite: 3, 9].

### 3.1 Resource: `Faciqor.Accounts.User` (Tabelle: `users`)

| Attribut | Typ | Pflicht | Constraints / Beschreibung |
| :--- | :--- | :--- | :--- |
| `id` | `:uuid` | Ja | Primary Key (`uuid_primary_key`)[cite: 9]. |
| `email` | `:ci_string` | Ja | Unique (`citext`). Primärer Identifikationsanker. |
| `handle` | `:ci_string` | Ja | Unique (`citext`), Format: `^[a-z0-9][a-z0-9_-]{2,30}$`. Wird beim Signup automatisch generiert, falls nicht angegeben. |
| `hashed_password` | `:string` | Nein | `sensitive? true`. Nur gesetzt bei Nutzung der Passwort-Strategie[cite: 9]. |
| `email_confirmed_at` | `:utc_datetime_usec` | Nein | `nil` bei unbestätigtem Passwort-Signup; sofort gesetzt bei Google OAuth & Magic Link[cite: 9]. |
| `deleted_at` | `:utc_datetime_usec` | Nein | `nil` im Normalbetrieb. Wenn gesetzt: Konto befindet sich in der 60-tägigen Soft-Delete-Wiederherstellungsfrist. |
| `inserted_at` | `:utc_datetime_usec` | Ja | Automatischer Create-Timestamp (Startpunkt für die 14-Tage-Verifizierungsfrist)[cite: 9]. |
| `updated_at` | `:utc_datetime_usec` | Ja | Automatischer Update-Timestamp[cite: 9]. |

**Berechnete Attribute (`calculations`):**
- `email_verified?` (`:boolean`): `expr(not is_nil(email_confirmed_at))`
- `verification_grace_expired?` (`:boolean`): `expr(is_nil(email_confirmed_at) and inserted_at < ago(14, :day))`
- `purge_at` (`:utc_datetime_usec`): `expr(datetime_add(deleted_at, 60, :day))`

### 3.2 Authentifizierungs-Hilfsressourcen (`AshAuthentication`)
- **`Faciqor.Accounts.Token` (Tabelle: `user_tokens`):** Verwaltet Session-, Magic-Link-, Confirmation- und Reset-Tokens[cite: 9].
- **`Faciqor.Accounts.UserIdentity` (Tabelle: `user_identities`):** Verknüpft OAuth2-Provider (Google `uid`, `strategy: :google`) mit `Faciqor.Accounts.User`, sodass sich ein Nutzer mit derselben E-Mail abwechselnd per Google, Magic Link oder Passwort anmelden kann (Account Linking)[cite: 9].
- **`Faciqor.Accounts.ApiToken` (Tabelle: `api_tokens`):** Personal Access Tokens (PAT) für den Zugriff über die Go-CLI und gRPC[cite: 3].
  - Attribute: `id`, `user_id`, `name` (z. B. "Laptop CLI"), `token_hash` (`sensitive? true`), `last_used_at`, `expires_at`, `revoked_at`, `inserted_at`.

### 3.3 Resource: `Faciqor.Accounts.Organization` (Tabelle: `organizations`)

| Attribut | Typ | Pflicht | Constraints / Beschreibung |
| :--- | :--- | :--- | :--- |
| `id` | `:uuid` | Ja | Primary Key (`tenant_id` für alle späteren Domänen-Ressourcen)[cite: 3, 9]. |
| `handle` | `:ci_string` | Ja | Unique (`citext`), Format: `^[a-z0-9][a-z0-9_-]{2,30}$`. URL- und CLI-Bezeichner der Organisation. |
| `primary_focus` | `:atom` | Ja | Enum: `:property_owner` (Eigentümer/Bestandshalter), `:property_manager` (Hausverwaltung), `:service_provider` (Dienstleister/KMU)[cite: 1, 6]. |
| `display_name` | `:string` | Nein | Optionaler Anzeigename (Fallback im UI: `@handle`). |
| `legal_name` | `:string` | Nein | Offizielle Firmenbezeichnung laut Handelsregister/Gewerbeanmeldung[cite: 10]. |
| `legal_form` | `:string` | Nein | Rechtsform (z. B. Einzelunternehmen, GbR, GmbH, WEG)[cite: 1]. |
| `street_address` | `:string` | Nein | Straße und Hausnummer. |
| `postal_code` | `:string` | Nein | Postleitzahl. |
| `city` | `:string` | Nein | Ort. |
| `country_code` | `:string` | Nein | ISO 3166-1 alpha-2 (Default: `"DE"`). |
| `tax_id` | `:string` | Nein | Steuernummer (Vorbereitung für EN 16931 E-Rechnung)[cite: 1, 6]. |
| `vat_id` | `:string` | Nein | USt-IdNr. (Vorbereitung für EN 16931 E-Rechnung)[cite: 1, 6]. |
| `contact_email` | `:ci_string` | Nein | Öffentliche/formale Rechnungseingangs- oder Kontaktadresse. |
| `deleted_at` | `:utc_datetime_usec` | Nein | Gesetzt, wenn Organisation manuell gelöscht wurde oder der letzte `:owner` sein Konto gelöscht hat. |
| `deletion_reason` | `:atom` | Nein | Enum: `:manual_by_owner` oder `:orphaned_by_last_owner`. |
| `inserted_at` / `updated_at` | `:utc_datetime_usec` | Ja | Automatische Zeitstempel[cite: 9]. |

### 3.4 Resource: `Faciqor.Accounts.OrganizationMembership` (Tabelle: `organization_memberships`)

Bildet die **M:N-Beziehung** zwischen `User` und `Organization` ab.

| Attribut | Typ | Pflicht | Constraints / Beschreibung |
| :--- | :--- | :--- | :--- |
| `id` | `:uuid` | Ja | Primary Key[cite: 9]. |
| `user_id` | `:uuid` | Ja | Foreign Key -> `users.id`. |
| `organization_id` | `:uuid` | Ja | Foreign Key -> `organizations.id`. |
| `role` | `:atom` | Ja | Enum: `:owner`, `:member`, `:guest`. |
| `inserted_at` / `updated_at` | `:utc_datetime_usec` | Ja | Automatische Zeitstempel[cite: 9]. |

- **Unique Identity:** `unique_index [:user_id, :organization_id]` (Ein User hat pro Organisation genau eine definierte Rolle).

---

## 4. Fachliche Geschäftslogik & Workflows

### 4.1 Authentifizierung & Auto-Handle-Generierung
1. **Unterstützte Strategien (`AshAuthentication`):**
   - **Email / Password:** Klassische Registrierung und Anmeldung[cite: 9]. Löst beim Signup den Versand einer Bestätigungs-E-Mail aus, lässt den Nutzer aber sofort einloggen.
   - **Magic Link:** Passwortloser Login/Signup per E-Mail-Link[cite: 9]. Setzt beim Einlösen automatisch `email_confirmed_at = DateTime.utc_now()`, falls noch `nil`.
   - **Google OAuth2:** Login/Signup über Google[cite: 9]. Verknüpft bestehende User anhand der verifizierten E-Mail-Adresse und setzt `email_confirmed_at = DateTime.utc_now()`, falls noch `nil`.
2. **Automatische Handle-Generierung beim Signup:**
   - Gibt der Nutzer beim Signup kein `handle` an (insb. bei Magic Link und Google OAuth), generiert eine Ash `Change`-Funktion (`Faciqor.Accounts.Changes.GenerateDefaultHandle`) ein eindeutiges Handle:
     - Basis ist der lokale Teil der E-Mail-Adresse (vor dem `@`), konvertiert zu Kleinbuchstaben, Sonderzeichen ersetzt durch `-`.
     - Ist dieses Handle bereits vergeben oder kürzer als 3 Zeichen, wird ein 4-stelliger kryptografischer Zufalls-Suffix angehängt (z. B. `max-a8f2`).

### 4.2 Die 14-Tage-Verifizierungsregel & Sicherheitsschranken
1. **Grace Period (Tag 0 bis Tag 14):**
   - Ein Nutzer mit `email_confirmed_at == nil` darf sich im Web-UI (`faciqor_web`) anmelden[cite: 3], sein Profil (`handle`) bearbeiten und Organisationen anlegen.
   - Im Web-UI wird permanent ein Warnbanner (`--fq-status-warning`) angezeigt[cite: 12].
2. **System-Einschränkungen für unverifizierte Nutzer (`email_confirmed_at == nil`):**
   - **Kein API-/CLI-Zugriff:** Das Erstellen von `ApiToken`-Datensätzen sowie jeder gRPC-Aufruf über `faciqor_grpc` ist per Ash-Policy verboten (`Forbidden`)[cite: 3, 9].
   - **Keine ausgehende Systemkommunikation:** Unverifizierte Konten dürfen keine E-Mails, Einladungen oder externen Webhooks auslösen.
3. **Ablauf der 14 Tage (`verification_grace_expired? == true`):**
   - Ein Phoenix LiveView `on_mount`-Hook leitet den Nutzer zwingend auf die Route `/verify-email-required` um. Alle anderen Routen sind blockiert, bis der Bestätigungslink geklickt wurde.

### 4.3 Organisationsverwaltung (M:N)
1. **Organisation erstellen (`create_organization`):**
   - Pflichteingaben: `handle` und `primary_focus` (`:property_owner`, `:property_manager` oder `:service_provider`)[cite: 1, 6]. Alle weiteren Stammdaten sind optional.
   - Innerhalb derselben Datenbank-Transaktion (`after_action` Hook in Ash) wird automatisch ein `OrganizationMembership`-Eintrag für den aktuellen `actor` mit `role: :owner` angelegt[cite: 9].
2. **Autorisierungs-Policies (`Ash.Policy.Authorizer`):**
   - **Lesen (`read`):** Jeder User sieht alle Organisationen, in denen er eine aktive Membership (`:owner`, `:member`, `:guest`) besitzt[cite: 9].
   - **Bearbeiten (`update`) & Soft-Delete (`soft_delete`):** Ausschließlich User mit einer Membership der Rolle `:owner` für diese spezifische Organisation dürfen deren Profil bearbeiten oder die Löschung anstoßen[cite: 9].

### 4.4 Soft-Delete, 60-Tage-Wiederherstellung & Kaskadierung
1. **Konto-Löschung anstoßen (`soft_delete_user`):**
   - Der User kann sein Konto jederzeit löschen. Dabei wird `user.deleted_at = DateTime.utc_now()` gesetzt.
   - **Kaskadierungs-Prüfung (Letzter Owner):** In derselben Transaktion ermittelt das System alle Organisationen, in denen der User die Rolle `:owner` hält, und prüft, ob dort noch mindestens ein weiterer aktiver User (`user.deleted_at == nil`) die Rolle `:owner` besitzt.
   - Ist der löschende User der **einzige/letzte Owner** einer Organisation, wird auch bei dieser Organisation `organization.deleted_at = DateTime.utc_now()` und `deletion_reason = :orphaned_by_last_owner` gesetzt.
   - Alle aktiven Sessions und `ApiToken` des Users werden sofort widerrufen (`revoked_at` gesetzt).
2. **Wiederherstellung innerhalb von 60 Tagen (`restore_user`):**
   - Loggt sich ein User mit gesetztem `deleted_at` innerhalb von 60 Tagen erneut im Web ein, erscheint eine dedizierte Wiederherstellungs-Ansicht.
   - Bei Bestätigung wird `user.deleted_at = nil` gesetzt. Alle Organisationen, bei denen der User `:owner` ist und `deletion_reason == :orphaned_by_last_owner` steht, werden automatisch mit reaktiviert (`deleted_at = nil`, `deletion_reason = nil`).
3. **Endgültige Löschung nach 60 Tagen (`AshOban`):**
   - Ein täglicher `AshOban`-Job (`@daily`) prüft alle `Organization`- und `User`-Datensätze mit `deleted_at < ago(60, :day)` und führt die physische Löschung (`destroy`) inkl. aller abhängigen Organisationsdaten durch[cite: 9].

---

## 5. Schnittstellenvertrag: gRPC & Go-CLI (`proto/` & `cli/`)

### 5.1 Protocol Buffers (`proto/faciqor/v1/identity.proto`)

```protobuf
syntax = "proto3";

package faciqor.v1;
option go_package = "faciqor/pkg/api/v1;v1";

enum OrganizationFocus {
  ORGANIZATION_FOCUS_UNSPECIFIED = 0;
  ORGANIZATION_FOCUS_PROPERTY_OWNER = 1;
  ORGANIZATION_FOCUS_PROPERTY_MANAGER = 2;
  ORGANIZATION_FOCUS_SERVICE_PROVIDER = 3;
}

enum MembershipRole {
  MEMBERSHIP_ROLE_UNSPECIFIED = 0;
  MEMBERSHIP_ROLE_OWNER = 1;
  MEMBERSHIP_ROLE_MEMBER = 2;
  MEMBERSHIP_ROLE_GUEST = 3;
}

service IdentityService {
  // User Profile
  rpc GetMyProfile (GetMyProfileRequest) returns (UserProfileResponse);
  rpc UpdateMyProfile (UpdateMyProfileRequest) returns (UserProfileResponse);
  rpc ChangePassword (ChangePasswordRequest) returns (ChangePasswordResponse);
  rpc RequestEmailChange (RequestEmailChangeRequest) returns (RequestEmailChangeResponse);
  rpc RequestAccountDeletion (RequestAccountDeletionRequest) returns (RequestAccountDeletionResponse);

  // Personal Access Tokens (PAT Governance)
  rpc ListApiTokens (ListApiTokensRequest) returns (ListApiTokensResponse);
  rpc CreateApiToken (CreateApiTokenRequest) returns (CreateApiTokenResponse);
  rpc RevokeApiToken (RevokeApiTokenRequest) returns (RevokeApiTokenResponse);

  // Organizations
  rpc CreateOrganization (CreateOrganizationRequest) returns (OrganizationResponse);
  rpc ListMyOrganizations (ListMyOrganizationsRequest) returns (ListMyOrganizationsResponse);
  rpc GetOrganization (GetOrganizationRequest) returns (OrganizationResponse);
  rpc UpdateOrganization (UpdateOrganizationRequest) returns (OrganizationResponse);
  rpc SoftDeleteOrganization (SoftDeleteOrganizationRequest) returns (OrganizationResponse);
}

message GetMyProfileRequest {}

message UpdateMyProfileRequest {
  optional string handle = 1;
  optional string display_name = 2;
  optional string first_name = 3;
  optional string last_name = 4;
  optional string phone = 5;
  optional string timezone = 6;
  optional string locale = 7;
}

message UserProfileResponse {
  string id = 1;
  string email = 2;
  string handle = 3;
  bool email_verified = 4;
  string inserted_at = 5;
  string display_name = 6;
  string first_name = 7;
  string last_name = 8;
  string phone = 9;
  string timezone = 10;
  string locale = 11;
  optional string pending_email = 12;
}

message ChangePasswordRequest {
  string current_password = 1;
  string new_password = 2;
}

message ChangePasswordResponse {
  bool success = 1;
}

message RequestEmailChangeRequest {
  string new_email = 1;
}

message RequestEmailChangeResponse {
  string pending_email = 1;
}

message ApiTokenItem {
  string id = 1;
  string name = 2;
  string token_prefix = 3;
  string scopes = 4;
  string inserted_at = 5;
  optional string last_used_at = 6;
  optional string expires_at = 7;
  optional string revoked_at = 8;
}

message ListApiTokensRequest {}

message ListApiTokensResponse {
  repeated ApiTokenItem tokens = 1;
}

message CreateApiTokenRequest {
  string name = 1;
  int32 expires_in_days = 2;
  string scopes = 3;
}

message CreateApiTokenResponse {
  string id = 1;
  string name = 2;
  string plain_token = 3;
  string token_prefix = 4;
  string scopes = 5;
  optional string expires_at = 6;
}

message RevokeApiTokenRequest {
  string id = 1;
}

message RevokeApiTokenResponse {
  bool success = 1;
}

message RequestAccountDeletionRequest {}

message RequestAccountDeletionResponse {
  string purge_scheduled_at = 1;
  repeated string orphaned_organization_handles = 2;
}

message CreateOrganizationRequest {
  string handle = 1;
  OrganizationFocus primary_focus = 2;
  optional string display_name = 3;
  optional string legal_name = 4;
  optional string legal_form = 5;
  optional string street_address = 6;
  optional string postal_code = 7;
  optional string city = 8;
  optional string country_code = 9;
  optional string tax_id = 10;
  optional string vat_id = 11;
  optional string contact_email = 12;
}

message UpdateOrganizationRequest {
  string id_or_handle = 1;
  optional string handle = 2;
  optional OrganizationFocus primary_focus = 3;
  optional string display_name = 4;
  optional string legal_name = 5;
  optional string legal_form = 6;
  optional string street_address = 7;
  optional string postal_code = 8;
  optional string city = 9;
  optional string country_code = 10;
  optional string tax_id = 11;
  optional string vat_id = 12;
  optional string contact_email = 13;
}

message GetOrganizationRequest {
  string id_or_handle = 1;
}

message SoftDeleteOrganizationRequest {
  string id_or_handle = 1;
}

message OrganizationResponse {
  string id = 1;
  string handle = 2;
  OrganizationFocus primary_focus = 3;
  MembershipRole my_role = 4;
  string display_name = 5;
  string legal_name = 6;
  string legal_form = 7;
  string street_address = 8;
  string postal_code = 9;
  string city = 10;
  string country_code = 11;
  string tax_id = 12;
  string vat_id = 13;
  string contact_email = 14;
  optional string deleted_at = 15;
}

message ListMyOrganizationsRequest {}

message ListMyOrganizationsResponse {
  repeated OrganizationResponse organizations = 1;
}
```

### 5.2 gRPC-Server & Interceptor-Regeln (`backend/lib/faciqor_grpc/`)
1. **Authentifizierungs-Interceptor (`FaciqorGrpc.Interceptors.Auth`):**
   - Extrahiert den Header `authorization: Bearer fq_pat_<token>` aus den gRPC-Metadaten.
   - Prüft den SHA-256-Hash gegen `Faciqor.Accounts.ApiToken` (`revoked_at == nil` und `expires_at > now()`).
   - Lädt den zugehörigen `User` (`deleted_at == nil`) und setzt ihn als Ash `actor` in den Request-Kontext[cite: 9].
2. **E-Mail-Verifizierungs-Gate:**
   - Ist beim geladenen `User` das Feld `email_confirmed_at == nil`, bricht der Interceptor den Request sofort mit dem gRPC-Statuscode `PERMISSION_DENIED` (`7`) und der Meldung `"Email verification required for API and CLI access"` ab.
3. **Fehler-Mapping (Ash -> gRPC Status):**
   - `Ash.Error.Invalid` (z. B. Handle bereits vergeben oder ungültiges Format) $\rightarrow$ `INVALID_ARGUMENT` (`3`) bzw. `ALREADY_EXISTS` (`6`).
   - `Ash.Error.Forbidden` (z. B. `:member` versucht Organisation zu bearbeiten) $\rightarrow$ `PERMISSION_DENIED` (`7`)[cite: 9].
   - `Ash.Error.Query.NotFound` $\rightarrow$ `NOT_FOUND` (`5`).

### 5.3 Go-CLI Befehlsstruktur & lokale Konfiguration (`cli/`)
1. **Konfigurationsdatei:**
   - Pfad: `~/.config/faciqor/config.yaml` (bzw. `os.UserConfigDir()`).
   - Felder: `endpoint` (z. B. `localhost:50051`), `token` (Personal Access Token), `default_org` (optionales Standard-Organisations-Handle).
2. **Globale CLI-Flags:**
   - `--json`: Gibt alle Antworten als strukturiertes JSON auf `stdout` aus (für Skripte und KI-Agenten).
   - `--endpoint`: Überschreibt die Server-Adresse.
3. **Verbindliche CLI-Befehle (Meilenstein 1):**
   ```bash
   # Authentifizierung & Token-Governance
   faciqor auth login --token <fq_pat_...>
   faciqor auth status
   faciqor auth logout
   faciqor auth token list
   faciqor auth token create --name <name> [--expires-in <days>] [--scopes <scopes>]
   faciqor auth token revoke <token-id>

   # Eigenes Benutzerprofil
   faciqor profile show
   faciqor profile update [--handle <new-handle>] [--name <display-name>] [--first-name <first>] [--last-name <last>] [--phone <phone>] [--timezone <tz>] [--locale <de|en>]
   faciqor profile password --current <current-pass> --new <new-pass>
   faciqor profile email-change --new-email <new-email>
   faciqor profile delete [--yes]

   # Organisationsverwaltung
   faciqor org list
   faciqor org create --handle <handle> --focus <owner|manager|provider> [--display-name "..."] [--legal-name "..."]
   faciqor org show <id-or-handle>
   faciqor org update <id-or-handle> [--handle ...] [--focus ...] [--legal-name ...] [--legal-form ...] [--street ...] [--postal-code ...] [--city ...] [--tax-id ...] [--vat-id ...] [--contact-email ...]
   faciqor org delete <id-or-handle> [--yes]
   ```

---

## 6. UI/UX-Spezifikation für `faciqor_web` (Phoenix LiveView)

Alle Ansichten in `backend/lib/faciqor_web/` müssen zwingend die Vorgaben aus `docs/ui_design_guidelines.md` und `FaciqorWeb.CoreComponents` einhalten[cite: 3, 12].

### 6.1 Verbindliche Design-System-Vorgaben
- **3-Schichten-Token-Modell:** Ausschließliche Nutzung der semantischen CSS-Variablen (`--fq-color-primary`, `--fq-color-bg-surface`, `--fq-color-bg-muted`, `--fq-status-warning`, `--fq-status-danger`)[cite: 12].
- **Typografie:** `Inter` (`--fq-font-sans`) für Fließtext und Labels; `JetBrains Mono` (`--fq-font-mono` / Klasse `fq-mono`) zwingend für alle `@handles`, UUIDs, Zeitstempel und API-Tokens[cite: 12].
- **Geometrie & Dichte (Desktop-First):** 4px-Basisraster; Standard-Höhe für Inputs und Buttons ist `36px` (`lg:h-9`) auf Desktop-Viewports ($\ge 1024\text{px}$) und `44px` (`h-11`) auf Touch-Geräten ($< 1024\text{px}$)[cite: 12].
- **Tastatur-Bedienbarkeit & GoBD-Zustände:** Jedes interaktive Control zeigt bei `:focus-visible` den `2px solid #2563EB` Fokus-Ring[cite: 12]. Nicht editierbare Felder für `:member` und `:guest` nutzen den `readonly`-Zustand (voller Textkontrast `#0F172A`, Hintergrund `#F1F5F9` und Schloss-Icon) statt `disabled`[cite: 12].

### 6.2 Authentifizierungs-Workflow (`/sign-in` & `/register`)
1. **Identifier-First Auth-Card:**
   - Zentrierte Karte auf `--fq-color-bg-app` (`#F8FAFC`)[cite: 12].
   - **Primäre Aktion:** Button *"Weiter mit Google"* (OAuth2)[cite: 9].
   - **Sekundäre Aktion (E-Mail-basiert):** Eingabefeld `E-Mail-Adresse` mit einem klaren Umschalter (Tabs):
     - **Tab 1: „Magic Link“ (Empfohlener Standard):** Sendet nach Eingabe der E-Mail sofort einen Einmal-Anmeldelink; benötigt kein Passwort[cite: 9].
     - **Tab 2: „Passwort“:** Ermöglicht klassischen Login bzw. Registrierung mit E-Mail und Passwort (min. 12 Zeichen)[cite: 9].
2. **Verzicht auf Pflicht-Handle im Signup-Screen:**
   - Um Abbrüche beim Onboarding zu minimieren, wird das `handle` beim ersten Signup nicht abgefragt, sondern im Hintergrund automatisch aus der E-Mail generiert (siehe Abschnitt 4.1) und kann jederzeit im Profil geändert werden.

### 6.3 App-Shell, Navigation & Empty-State-Dashboard (`/dashboard`)
1. **Permanentes 14-Tage-Verifizierungs-Banner:**
   - Solange `current_user.email_confirmed_at == nil` ist, wird am oberen Rand der App-Shell eine nicht ausblendbare Statusleiste in `--fq-status-warning` (`#FFFBEB` / Text `#92400E`) gerendert[cite: 12]:
     *"Bitte bestätigen Sie Ihre E-Mail-Adresse innerhalb der nächsten X Tage. Bis zur Bestätigung sind CLI-/API-Zugriffe und ausgehende E-Mails deaktiviert."* Inklusive Button *"Bestätigungs-E-Mail erneut senden"*.
2. **Multi-Tenant-Switcher (Sidebar / Header):**
   - Zeigt die aktuell ausgewählte Organisation (`@org-handle` in `fq-mono` + Rollen-Badge `Owner`, `Member` oder `Guest`)[cite: 12].
   - Ein Klick öffnet das Dropdown zum schnellen Wechsel zwischen allen Organisationen des Nutzers (M:N) sowie die Aktion *"+ Neue Organisation gründen"*.
   - **Benutzerprofil-Avatar:** Zeigt visuell Initialen des Benutzers mit Direktlink zu `/settings/profile`.
3. **Geführter Empty State (wenn der User 0 Organisationen angehört):**
   - Besitzt der Nutzer nach dem Login noch keine `OrganizationMembership`, zeigt `/dashboard` keine leeren ERP-Menüs, sondern ein fokussiertes Onboarding-Grid mit zwei Karten:
     - **Karte 1 (Primär): „Erste Organisation gründen“** – Öffnet direkt den Erstellungs-Dialog.
     - **Karte 2 (Sekundär): „Benutzerprofil & CLI einrichten“** – Führt zu `/settings/profile`, um das automatisch generierte `@handle` anzupassen oder ein Personal Access Token für die Go-CLI zu erzeugen.
4. **Wiederherstellungs-Ansicht bei aktivem Soft-Delete (`/account/restore`):**
   - Loggt sich ein Nutzer ein, dessen `deleted_at` gesetzt ist, blockiert ein LiveView `on_mount`-Hook alle regulären Ansichten und zeigt ausschließlich die Wiederherstellungs-Maske mit dem genauen Löschdatum (`purge_at`) und dem Button *"Konto & zugehörige Organisationen jetzt wiederherstellen"*.

### 6.4 Umfassende Benutzerprofil-Verwaltung (`/settings/profile`)
Die Seite gliedert sich in eine modulare 7-Karten-Architektur:
1. **Karte 1 – Persönliche Stammdaten & Identität:**
   - `Handle`: `<.input monospace={true} />` mit vorangestelltem `@`-Präfix und Live-Validierung (`phx-change="validate_profile"`, `phx-debounce="300"`). Prüft Format und Eindeutigkeit in Echtzeit.
   - `Anzeigename` (`display_name`), `Vorname` (`first_name`), `Nachname` (`last_name`), `Telefon / Mobilfunk` (`phone`).
   - `Zeitzone` (`timezone`, z. B. `Europe/Berlin`) & `Sprache` (`locale`, z. B. `de` / `en`).
2. **Karte 2 – Primäre E-Mail & Verifizierung:**
   - `E-Mail-Adresse`: Readonly-Anzeige mit Verifizierungs-Badge (`Verifiziert` / `Unbestätigt`).
   - 2-Schritt-Änderungsprozess: Neuer E-Mail-Vorschlag setzt `pending_email` (gelbes Warn-Banner mit Bestätigungs- und Abbruch-Button). Erst nach Verifizierung wird die primäre Adresse überschrieben.
3. **Karte 3 – Sicherheit & Kennwort:**
   - Kennwort ändern (Verifikation des alten Kennworts, Mindestlänge 8 Zeichen, Bestätigungsfeld).
   - Bei Accounts, die ursprünglich via Magic Link oder Google OAuth registriert wurden: Initiales Kennwort vergeben.
4. **Karte 4 – Verknüpfte Anmeldeverfahren (SSO):**
   - Übersicht der verknüpften Identitäten (z. B. Google Workspace / OAuth2).
5. **Karte 5 – Personal Access Tokens (Go-CLI & gRPC):**
   - Listet alle `ApiToken` des Nutzers (`Bezeichnung`, `Prefix`, `Berechtigung`, `Erstellt am`, `Gültigkeit`, `Zuletzt genutzt`, Button `Widerrufen`).
   - Token-Erstellung mit Name, Scopes (`all`, `read_only`, `cli`) und Ablaufzeitraum (30/90/180/365 Tage oder unbegrenzt).
   - Sicherheits-Gate: Deaktiviert, solange `email_confirmed_at == nil`.
   - Einmalige Klartext-Anzeige mit Clipboard-Copy und fertigem `faciqor auth login --token <token>` Kommando.
6. **Karte 6 – Zugehörige Organisationen & Rollen:**
   - Schnelle Übersicht aller Organisationen mit Rolle (`Owner`, `Member`, `Guest`) und Direktverlinkung.
7. **Karte 7 – Gefahrenzone (Konto löschen / 60-Tage-Soft-Delete):**
   - Rahmen in `--fq-status-danger` (`#EF4444`).
   - **Dynamische Kaskadierungs-Warnung:** Listet alle Organisationen, in denen der Nutzer der **letzte aktive `:owner`** ist.
   - Erfordert zur Bestätigung die Eingabe des eigenen `@handle` in ein Bestätigungsfeld, bevor die Löschung zur Vormerkung ausgeführt wird.

### 6.5 Organisationsverwaltung & Stammdaten (`/orgs/new` & `/orgs/:handle/settings`)
1. **Anlagedialog (`/orgs/new`):**
   - Minimalistischer 1-Schritt-Workflow:
     1. **Pflichtfeld `Handle`:** `<.input monospace={true} label="Organisations-Handle" placeholder="meine-hausverwaltung" />`[cite: 12].
     2. **Pflichtauswahl `Tätigkeitsschwerpunkt` (`primary_focus`):** Drei interaktive Radio-Cards (Tastatur-navigierbar)[cite: 12]:
        - **Eigentümer / Bestandshalter (`:property_owner`):** *„Ich verwalte eigene Liegenschaften oder WEG-Bestände im Direkt- oder Hybridmodell.“*[cite: 1, 10]
        - **Hausverwaltung (`:property_manager`):** *„Ich verwalte Immobilienbestände für Dritte, prüfe Belege und übernehme Buchungsstapel.“*[cite: 1, 10]
        - **Dienstleister / KMU (`:service_provider`):** *„Ich führe Hausmeister-, Reinigungs-, Grünflächen- oder Handwerksleistungen durch.“*[cite: 1, 10]
     3. Optionaler Link *"Formale Unternehmensdaten sofort ergänzen"* (klappt die optionalen Felder auf) oder direkter Abschluss per Button *"Organisation gründen"*.
2. **Organisations-Einstellungen (`/orgs/:handle/settings`):**
   - **Rollenbasierte Ansicht:**
     - Ist der aktuelle User `:owner`, sind alle Felder normal editierbar.
     - Ist der aktuelle User `:member` oder `:guest`, werden alle Eingabefelder mit `readonly={true}` (voller Kontrast + Schloss-Icon) gerendert und der Speichern-Button ausgeblendet[cite: 12].
   - **Sektion A – Identität & Schwerpunkt (Pflichtfelder):**
     - `handle` (`fq-mono`) und `primary_focus`[cite: 12].
   - **Sektion B – Formale Unternehmensdaten & Rechnungsstellung (Alle Felder optional):**
     - `display_name` (Anzeigename), `legal_name` (Offizieller Firmenname), `legal_form` (Rechtsform), `street_address`, `postal_code`, `city`, `country_code` (Standard: `DE`), `tax_id` (Steuernummer), `vat_id` (USt-IdNr., `fq-mono`), `contact_email`[cite: 1, 12].
   - **Sektion C – Gefahrenzone (Nur für `:owner` sichtbar):**
     - Button *"Organisation zur Löschung vormerken (60 Tage Frist)"* (`variant="danger"`), setzt `organization.deleted_at = DateTime.utc_now()` und `deletion_reason = :manual_by_owner`[cite: 12].

---

## 7. Qualitätssicherung, Tests & Akzeptanzkriterien (Definition of Done)

Ein Coding-Agent oder Entwickler darf Meilenstein 1 erst als abgeschlossen markieren, wenn alle nachfolgenden Testsuiten und Abnahmekriterien (`mix test` und `go test ./...`) fehlerfrei durchlaufen.

### 7.1 Automatisierte Backend- & Policy-Tests (`backend/test/faciqor/accounts/`)
1. **Multi-Auth & Account Linking:**
   - Testet die Registrierung per Passwort (`email_confirmed_at == nil`), per Magic Link (`email_confirmed_at != nil`) und per Google OAuth2 (`email_confirmed_at != nil`)[cite: 9].
   - Verifiziert, dass ein bestehender Passwort-User, der sich anschließend mit derselben E-Mail über Google OAuth oder Magic Link anmeldet, mit demselben `User`-Datensatz verknüpft wird und `email_confirmed_at` gesetzt wird.
2. **Auto-Handle-Generierung:**
   - Prüft, dass bei fehlendem Handle aus `max.mustermann@example.com` automatisch `max-mustermann` erzeugt wird und bei Kollisionen ein eindeutiger Suffix (`max-mustermann-xxxx`) angehängt wird.
3. **14-Tage-Verifizierungsregel & API-Gate:**
   - Prüft, dass ein User mit `email_confirmed_at == nil` kein `ApiToken` erstellen kann (`Ash.Error.Forbidden`)[cite: 9].
   - Prüft, dass die Calculation `verification_grace_expired?` exakt nach `inserted_at < ago(14, :day)` bei fehlender Bestätigung auf `true` wechselt.
4. **M:N-Autorisierungs-Policies (`Organization` & `OrganizationMembership`):**
   - Ein User kann in `Org A` `:owner`, in `Org B` `:member` und in `Org C` `:guest` sein.
   - `read` gibt alle drei Organisationen zurück; `update` und `soft_delete` sind ausschließlich für `Org A` erlaubt und werfen bei `Org B` und `Org C` `Ash.Error.Forbidden`[cite: 9].
5. **60-Tage-Soft-Delete & Kaskadierung:**
   - Löscht `User 1` sein Konto und ist er alleiniger `:owner` von `Org A`, während `Org B` noch `User 2` als zweiten `:owner` hat, wird `Org A` mit `deleted_at` und `deletion_reason: :orphaned_by_last_owner` markiert, `Org B` bleibt aktiv (`deleted_at == nil`).
   - Führt `User 1` innerhalb von 60 Tagen `restore_user` aus, werden `User 1` und `Org A` wiederhergestellt.
   - Der `AshOban`-Job löscht Datensätze mit `deleted_at < ago(60, :day)` endgültig aus der Datenbank[cite: 9].

### 7.2 LiveView-UI-Tests (`backend/test/faciqor_web/live/`)
1. **Onboarding & Empty State:**
   - Ein neu registrierter User ohne Organisation sieht auf `/dashboard` den geführten Empty State und das gelbe 14-Tage-Verifizierungsbanner[cite: 12].
2. **Grace-Period-Blocker:**
   - Ein unbestätigter User mit `inserted_at` vor 15 Tagen wird bei Aufruf von `/dashboard` oder `/settings/profile` zwingend auf `/verify-email-required` weitergeleitet.
3. **Rollenbasierte Formular-Darstellung:**
   - Auf `/orgs/:handle/settings` sieht ein `:owner` editierbare Felder, während ein `:member` oder `:guest` die Felder mit dem Attribut `readonly` vorfindet[cite: 12].

### 7.3 End-to-End gRPC- & Go-CLI-Integrationstests (`cli/`)
1. **Unverifizierter Zugriff:**
   - Ein gRPC-Aufruf mit einem Token eines Users, dessen `email_confirmed_at == nil` ist, wird vom Elixir-gRPC-Interceptor mit `PERMISSION_DENIED` abgewiesen.
2. **Vollständiger CLI-Durchlauf (Verifizierter User):**
   - `faciqor auth login --token <pat>` speichert das Token und gibt über `GetMyProfile` das korrekte `@handle` zurück.
   - `faciqor org create --handle meine-hv --focus manager` legt die Organisation inkl. `:owner`-Membership an.
   - `faciqor org update meine-hv --legal-name "Muster Hausverwaltung GmbH" --tax-id "12/345/67890"` aktualisiert die optionalen Stammdaten.
   - `faciqor org list --json` liefert ein valides JSON-Array mit der angelegten Organisation und `my_role: "MEMBERSHIP_ROLE_OWNER"`.

### 7.4 Übergabecheckliste für Meilenstein 1 (Abnahme-Kriterien)
- [ ] `buf lint` und `buf generate` laufen ohne Warnungen durch und aktualisieren `backend/lib/faciqor_grpc/generated/` sowie `cli/pkg/api/v1/`[cite: 3].
- [ ] Alle PostgreSQL-Migrationen (`citext`, `users`, `user_tokens`, `user_identities`, `api_tokens`, `organizations`, `organization_memberships`) lassen sich via `mix ecto.migrate` und `mix ecto.rollback` sauber ausführen[cite: 3].
- [ ] `mix compile --warnings-as-errors`, `mix format --check-formatted` und `mix test` sind zu 100 % grün.
- [ ] Die Go-CLI kompiliert fehlerfrei (`go build ./cmd/faciqor`) und besteht alle CLI-Tests (`go test ./...`)[cite: 3].