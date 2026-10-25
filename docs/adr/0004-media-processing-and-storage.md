# ADR 0004: Zentrale Bildverarbeitung, Speicherstrategie & Asynchrone Varianten

## Status
Akzeptiert (2026-10-25)

## Kontext
Faciqor benötigt an verschiedenen Stellen im Gesamtsystem Bildverarbeitungs- und Speicherfunktionen:
1. **Benutzer-Avatare:** Zur Identifikation im Web-Hub, CLI und in Einsatzberichten (nur vom Benutzer selbst änderbar).
2. **Organisations-/Firmenlogos:** Zur Mandanten-Individualisierung auf Formularen, Rechnungen und im Header (nur von Organisations-Ownern änderbar).
3. **Zukünftige Anforderungen:** Fotodokumentation von Mängeln, Leistungsnachweise bei Handwerkseinsätzen (GEFMA/BetrKV) und Zählerstandsfotos.

### Rahmenbedingungen & Anforderungen
- **Öffentlich vs. Geschützt:** Avatare und Firmenlogos sind öffentlich lesbar (`faciqor-public`), während Nachweise und Dokumente zugriffsgeschützt im Vault liegen (`faciqor-vault`).
- **Dateigröße & Dimensionen:** Uploads bis max. 5MB, kürzeste Seite mind. 512px, quadratisches Seitenverhältnis (1:1).
- **Benutzererlebnis Web:** Interaktiver Bildzuschnitt (CropperJS) direkt im Browser vor dem Speichern.
- **Benutzererlebnis CLI:** Strenge lokale Vorabprüfung (Format, Größe, quadratische Dimensionen $\ge$ 512px) vor dem Upload.
- **Asynchrone Varianten:** Automatische Erstellung von 4 WebP-Varianten (64x64, 128x128, 256x256, 512x512) nach dem Upload.
- **Datenschutz vs. Beweissicherheit:** Metadaten (EXIF/GPS) müssen für öffentliche Profil- und Logobilder zwingend entfernt werden (DSGVO/Privacy), während sie für gerichtsverwertbare Beweisbilder im Vault erhalten bleiben müssen.

---

## Entscheidung

### 1. Hex-Paket: `image` (auf Basis von `vix` / `libvips`)
Wir setzen auf das Hex-Paket `image` (`~> 0.54`), welches auf `vix` und der nativen C-Bibliothek `libvips` aufsetzt:
- **Performance & Speicher:** Deutlich schneller und speichereffizienter als ImageMagick (`mogrify`) oder rein elixirseitige Lösungen.
- **Keine Host-Abhängigkeiten:** `vix` liefert vorkompilierte `libvips`-Binaries für macOS, Linux und FreeBSD via `cc_precompiler` mit.
- **Funktionalität:** Native Unterstützung für EXIF-Entfernung (`strip_metadata: true`), WebP-Konvertierung und quadratische Skalierung mit Zentrumsschnitt (`crop: :center`).

### 2. Domänen-Architektur: Dedizierte Ash-Domain `Faciqor.Media`
Die Bildverarbeitung und Speicherlogik wird anwendungsweit in einer eigenen Ash-Domain gebündelt:
- `Faciqor.Media.StorageBlob`: Ash-Ressource für Metadaten (Bucket, Storage-Key, SHA-256, MIME-Type, Byte-Größe, Varianten-Map).
- `Faciqor.Media.ImageProcessing`: Validierungs- und Skalierungs-Engine (`validate_and_inspect_image/2`, `generate_webp_variants/3`).
- `Faciqor.Media.Storage`: S3-Adapter (`ex_aws_s3`) für Pre-Signed PUT-URLs, Uploads und Löschungen in SeaweedFS bzw. S3.
- `Faciqor.Media.Workers.ProcessImageVariants`: Oban-Worker für die asynchrone Generierung der 4 WebP-Thumbnails.
- `Faciqor.Accounts.User` und `Faciqor.Accounts.Organization` referenzieren `StorageBlob` via `avatar_blob_id` bzw. `logo_blob_id`.
- **Automatischer Cleanup:** Bei Austausch oder Löschung eines Avatars oder Logos werden Altdateien im S3-Storage sowie der verwaiste `StorageBlob`-Eintrag automatisch gelöscht.

### 3. API & Upload-Flow (Contract-First via gRPC)
Der Upload von Binärdaten erfolgt **niemals** über den gRPC-Server als RAW-Stream, sondern über einen Ticket-basierten Pre-Signed S3-Flow:
1. Client fordert Ticket an (`GetAvatarUploadTicket` / `GetOrganizationLogoUploadTicket`) unter Angabe von Content-Type, Größe und SHA-256.
2. Backend validiert Berechtigung (z. B. Owner-Rolle bei Organisationen), erzeugt einen `StorageBlob`-Datensatz und liefert eine zeitlich befristete Pre-Signed S3-PUT-URL zurück.
3. Client lädt die Originaldatei per HTTP-PUT direkt in den S3-Storage (`faciqor-public`).
4. Client ruft `SetAvatar` bzw. `SetOrganizationLogo` mit der `blob_id` auf.
5. Backend verknüpft den Blob mit der Ressource und queued einen Oban-Job zur Variantenberechnung.

### 4. Web UI & CLI
- **Phoenix LiveView:** Nutzt einen Hook `ImageCropper` (basierend auf CropperJS) in einem Modal. Nach der Auswahl schneidet der Benutzer das Bild auf ein exaktes 1:1-Quadrat zu. Der Canvas-Blob wird via LiveView-Upload übergeben.
- **Go CLI:** Implementiert in `cli/internal/media` eine Validierung via `image.DecodeConfig`, verifiziert $\ge 512\times 512$px und 1:1-Verhältnis, fordert das Ticket an, lädt per HTTP PUT hoch und aktualisiert das Profil bzw. die Organisation.

---

## Konsequenzen

### Positiv
- Einheitliche, performante Bildmanipulation für alle zukünftigen Anforderungen (Zählerstände, Schadensfotos).
- Serverlast für gRPC und Web wird minimiert, da Blobs direkt in den Objektspeicher wandern.
- Volle DSGVO-Konformität durch automatisches EXIF-Stripping bei öffentlichen Profilbildern.
- Revisionssicherheit und Entkopplung durch Ash-Ressourcen und relationale Verknüpfung.

### Zu beachten
- Lokale Testumgebungen benötigen SeaweedFS oder einen S3-kompatiblen Dienst (im Docker Compose vorkonfiguriert).
- Worker-Latenz: Bis die WebP-Varianten berechnet sind, liefert das System die URL der Originaldatei als Fallback aus.
