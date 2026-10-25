package cmd

import (
	"context"
	"fmt"
	"strings"

	"faciqor/internal/client"
	"faciqor/internal/config"
	"faciqor/internal/output"
	v1 "faciqor/pkg/api/v1"

	"github.com/spf13/cobra"
)

type Options struct {
	ConfigPath    string
	EndpointFlag  string
	JSONOutput    bool
	ClientFactory client.Factory
}

func NewRootCmd(opts *Options) *cobra.Command {
	if opts == nil {
		opts = &Options{}
	}
	if opts.ClientFactory == nil {
		opts.ClientFactory = client.DefaultFactory
	}

	rootCmd := &cobra.Command{
		Use:           "faciqor",
		Short:         "Faciqor CLI – Mandanten-, Profil- und ERP-Verwaltung",
		SilenceUsage:  true,
		SilenceErrors: true,
	}

	rootCmd.PersistentFlags().BoolVar(&opts.JSONOutput, "json", false, "Gibt alle Antworten als strukturiertes JSON auf stdout aus")
	rootCmd.PersistentFlags().StringVar(&opts.EndpointFlag, "endpoint", "", "Überschreibt die gRPC-Server-Adresse (z.B. localhost:50051)")

	rootCmd.AddCommand(newAuthCmd(opts))
	rootCmd.AddCommand(newProfileCmd(opts))
	rootCmd.AddCommand(newOrgCmd(opts))

	return rootCmd
}

func resolveClient(opts *Options) (v1.IdentityServiceClient, func() error, *config.Config, error) {
	cfg, err := config.Load(opts.ConfigPath)
	if err != nil {
		return nil, nil, nil, err
	}
	endpoint := cfg.Endpoint
	if opts.EndpointFlag != "" {
		endpoint = opts.EndpointFlag
	}
	cli, closeFn, err := opts.ClientFactory(endpoint, cfg.Token)
	if err != nil {
		return nil, nil, nil, err
	}
	return cli, closeFn, cfg, nil
}

// --- AUTH COMMANDS ---

func newAuthCmd(opts *Options) *cobra.Command {
	authCmd := &cobra.Command{
		Use:   "auth",
		Short: "Authentifizierung und Personal Access Token verwalten",
	}

	var token string
	loginCmd := &cobra.Command{
		Use:   "login",
		Short: "Personal Access Token speichern und Verbindung prüfen",
		RunE: func(cmd *cobra.Command, args []string) error {
			if token == "" {
				return fmt.Errorf("--token flag is required")
			}
			cfg, err := config.Load(opts.ConfigPath)
			if err != nil {
				return err
			}
			if opts.EndpointFlag != "" {
				cfg.Endpoint = opts.EndpointFlag
			}
			cfg.Token = token

			cli, closeFn, err := opts.ClientFactory(cfg.Endpoint, cfg.Token)
			if err != nil {
				return err
			}
			defer closeFn()

			profile, err := cli.GetMyProfile(context.Background(), &v1.GetMyProfileRequest{})
			if err != nil {
				return err
			}

			if err := config.Save(cfg, opts.ConfigPath); err != nil {
				return err
			}

			return output.PrintProfile(cmd.OutOrStdout(), profile, opts.JSONOutput)
		},
	}
	loginCmd.Flags().StringVar(&token, "token", "", "Personal Access Token (fq_pat_...)")

	statusCmd := &cobra.Command{
		Use:   "status",
		Short: "Aktuellen Authentifizierungsstatus anzeigen",
		RunE: func(cmd *cobra.Command, args []string) error {
			cli, closeFn, _, err := resolveClient(opts)
			if err != nil {
				return err
			}
			defer closeFn()

			profile, err := cli.GetMyProfile(context.Background(), &v1.GetMyProfileRequest{})
			if err != nil {
				return err
			}
			return output.PrintProfile(cmd.OutOrStdout(), profile, opts.JSONOutput)
		},
	}

	logoutCmd := &cobra.Command{
		Use:   "logout",
		Short: "Gespeichertes Token aus lokaler Konfiguration entfernen",
		RunE: func(cmd *cobra.Command, args []string) error {
			cfg, err := config.Load(opts.ConfigPath)
			if err != nil {
				return err
			}
			cfg.Token = ""
			if err := config.Save(cfg, opts.ConfigPath); err != nil {
				return err
			}
			if opts.JSONOutput {
				return output.PrintJSON(cmd.OutOrStdout(), map[string]bool{"logged_out": true})
			}
			fmt.Fprintln(cmd.OutOrStdout(), "Erfolgreich abgemeldet.")
			return nil
		},
	}

	authCmd.AddCommand(loginCmd, statusCmd, logoutCmd, newTokenCmd(opts))
	return authCmd
}

func newTokenCmd(opts *Options) *cobra.Command {
	tokenCmd := &cobra.Command{
		Use:   "token",
		Short: "Personal Access Tokens (PAT) verwalten",
	}

	listCmd := &cobra.Command{
		Use:   "list",
		Short: "Alle eigenen Personal Access Tokens auflisten",
		RunE: func(cmd *cobra.Command, args []string) error {
			cli, closeFn, _, err := resolveClient(opts)
			if err != nil {
				return err
			}
			defer closeFn()

			res, err := cli.ListApiTokens(context.Background(), &v1.ListApiTokensRequest{})
			if err != nil {
				return err
			}
			return output.PrintApiTokens(cmd.OutOrStdout(), res.Tokens, opts.JSONOutput)
		},
	}

	var name string
	var expiresInDays int32
	var scopes string
	createCmd := &cobra.Command{
		Use:   "create",
		Short: "Neues Personal Access Token erstellen",
		RunE: func(cmd *cobra.Command, args []string) error {
			if name == "" {
				return fmt.Errorf("--name is required")
			}
			cli, closeFn, _, err := resolveClient(opts)
			if err != nil {
				return err
			}
			defer closeFn()

			req := &v1.CreateApiTokenRequest{
				Name: name,
			}
			if cmd.Flags().Changed("expires-in-days") {
				req.ExpiresInDays = &expiresInDays
			}
			if cmd.Flags().Changed("scopes") {
				req.Scopes = &scopes
			}

			res, err := cli.CreateApiToken(context.Background(), req)
			if err != nil {
				return err
			}

			if opts.JSONOutput {
				return output.PrintJSON(cmd.OutOrStdout(), map[string]interface{}{
					"token":       res.Token,
					"plain_token": res.PlainToken,
				})
			}

			fmt.Fprintf(cmd.OutOrStdout(), "Token '%s' erfolgreich erstellt:\n", res.Token.Name)
			fmt.Fprintf(cmd.OutOrStdout(), "TOKEN: %s\n", res.PlainToken)
			fmt.Fprintln(cmd.OutOrStdout(), "Hinweis: Bitte speichern Sie dieses Token jetzt. Es wird nicht erneut angezeigt.")
			return nil
		},
	}
	createCmd.Flags().StringVar(&name, "name", "", "Bezeichnung des Tokens")
	createCmd.Flags().Int32Var(&expiresInDays, "expires-in-days", 365, "Gültigkeitsdauer in Tagen (0 für unbegrenzt)")
	createCmd.Flags().StringVar(&scopes, "scopes", "all", "Berechtigungs-Scopes (z.B. all, read_only, cli)")

	var tokenId string
	revokeCmd := &cobra.Command{
		Use:   "revoke",
		Short: "Personal Access Token widerrufen",
		RunE: func(cmd *cobra.Command, args []string) error {
			if tokenId == "" {
				return fmt.Errorf("--id is required")
			}
			cli, closeFn, _, err := resolveClient(opts)
			if err != nil {
				return err
			}
			defer closeFn()

			_, err = cli.RevokeApiToken(context.Background(), &v1.RevokeApiTokenRequest{
				TokenId: tokenId,
			})
			if err != nil {
				return err
			}

			if opts.JSONOutput {
				return output.PrintJSON(cmd.OutOrStdout(), map[string]bool{"revoked": true})
			}
			fmt.Fprintln(cmd.OutOrStdout(), "Token erfolgreich widerrufen.")
			return nil
		},
	}
	revokeCmd.Flags().StringVar(&tokenId, "id", "", "ID des zu widerrufenden Tokens")

	tokenCmd.AddCommand(listCmd, createCmd, revokeCmd)
	return tokenCmd
}

// --- PROFILE COMMANDS ---

func newProfileCmd(opts *Options) *cobra.Command {
	profileCmd := &cobra.Command{
		Use:   "profile",
		Short: "Eigenes Benutzerprofil verwalten",
	}

	showCmd := &cobra.Command{
		Use:   "show",
		Short: "Eigenes Benutzerprofil abrufen",
		RunE: func(cmd *cobra.Command, args []string) error {
			cli, closeFn, _, err := resolveClient(opts)
			if err != nil {
				return err
			}
			defer closeFn()

			profile, err := cli.GetMyProfile(context.Background(), &v1.GetMyProfileRequest{})
			if err != nil {
				return err
			}
			return output.PrintProfile(cmd.OutOrStdout(), profile, opts.JSONOutput)
		},
	}

	var handle, displayName, firstName, lastName, phone, timezone, locale string
	updateCmd := &cobra.Command{
		Use:   "update",
		Short: "Eigenes Profil aktualisieren",
		RunE: func(cmd *cobra.Command, args []string) error {
			req := &v1.UpdateMyProfileRequest{}
			hasChanges := false

			if cmd.Flags().Changed("handle") {
				clean := strings.TrimSpace(strings.TrimPrefix(handle, "@"))
				req.Handle = &clean
				hasChanges = true
			}
			if cmd.Flags().Changed("display-name") {
				req.DisplayName = &displayName
				hasChanges = true
			}
			if cmd.Flags().Changed("first-name") {
				req.FirstName = &firstName
				hasChanges = true
			}
			if cmd.Flags().Changed("last-name") {
				req.LastName = &lastName
				hasChanges = true
			}
			if cmd.Flags().Changed("phone") {
				req.Phone = &phone
				hasChanges = true
			}
			if cmd.Flags().Changed("timezone") {
				req.Timezone = &timezone
				hasChanges = true
			}
			if cmd.Flags().Changed("locale") {
				req.Locale = &locale
				hasChanges = true
			}

			if !hasChanges {
				return fmt.Errorf("mindestens eine Eigenschaft muss geändert werden (--handle, --display-name, etc.)")
			}

			cli, closeFn, _, err := resolveClient(opts)
			if err != nil {
				return err
			}
			defer closeFn()

			profile, err := cli.UpdateMyProfile(context.Background(), req)
			if err != nil {
				return err
			}
			return output.PrintProfile(cmd.OutOrStdout(), profile, opts.JSONOutput)
		},
	}
	updateCmd.Flags().StringVar(&handle, "handle", "", "Neues Benutzer-Handle")
	updateCmd.Flags().StringVar(&displayName, "display-name", "", "Anzeigename")
	updateCmd.Flags().StringVar(&firstName, "first-name", "", "Vorname")
	updateCmd.Flags().StringVar(&lastName, "last-name", "", "Nachname")
	updateCmd.Flags().StringVar(&phone, "phone", "", "Telefonnummer")
	updateCmd.Flags().StringVar(&timezone, "timezone", "", "Zeitzone (z. B. Europe/Berlin)")
	updateCmd.Flags().StringVar(&locale, "locale", "", "Sprachcode (z. B. de oder en)")

	var currentPass, newPass string
	passwordCmd := &cobra.Command{
		Use:   "password",
		Short: "Eigenes Kennwort ändern",
		RunE: func(cmd *cobra.Command, args []string) error {
			if currentPass == "" || newPass == "" {
				return fmt.Errorf("--current-password und --new-password sind erforderlich")
			}
			cli, closeFn, _, err := resolveClient(opts)
			if err != nil {
				return err
			}
			defer closeFn()

			_, err = cli.ChangePassword(context.Background(), &v1.ChangePasswordRequest{
				CurrentPassword: currentPass,
				NewPassword:     newPass,
			})
			if err != nil {
				return err
			}

			if opts.JSONOutput {
				return output.PrintJSON(cmd.OutOrStdout(), map[string]bool{"success": true})
			}
			fmt.Fprintln(cmd.OutOrStdout(), "Kennwort erfolgreich geändert.")
			return nil
		},
	}
	passwordCmd.Flags().StringVar(&currentPass, "current-password", "", "Aktuelles Passwort")
	passwordCmd.Flags().StringVar(&newPass, "new-password", "", "Neues Passwort (min. 8 Zeichen)")

	var newEmail string
	emailChangeCmd := &cobra.Command{
		Use:   "email-change",
		Short: "Änderung der primären E-Mail-Adresse anfordern",
		RunE: func(cmd *cobra.Command, args []string) error {
			if newEmail == "" {
				return fmt.Errorf("--email ist erforderlich")
			}
			cli, closeFn, _, err := resolveClient(opts)
			if err != nil {
				return err
			}
			defer closeFn()

			res, err := cli.RequestEmailChange(context.Background(), &v1.RequestEmailChangeRequest{
				NewEmail: newEmail,
			})
			if err != nil {
				return err
			}

			if opts.JSONOutput {
				return output.PrintJSON(cmd.OutOrStdout(), map[string]string{"pending_email": res.PendingEmail})
			}
			fmt.Fprintf(cmd.OutOrStdout(), "Bestätigungs-Anfrage an '%s' wurde vorgemerkt.\n", res.PendingEmail)
			return nil
		},
	}
	emailChangeCmd.Flags().StringVar(&newEmail, "email", "", "Neue E-Mail-Adresse")

	var confirmYes bool
	deleteCmd := &cobra.Command{
		Use:   "delete",
		Short: "Eigenes Benutzerkonto zur Löschung vormerken (60-Tage-Soft-Delete)",
		RunE: func(cmd *cobra.Command, args []string) error {
			if !confirmYes {
				return fmt.Errorf("bitte bestätigen Sie die Konto-Löschung mit --yes")
			}
			cli, closeFn, _, err := resolveClient(opts)
			if err != nil {
				return err
			}
			defer closeFn()

			res, err := cli.RequestAccountDeletion(context.Background(), &v1.RequestAccountDeletionRequest{})
			if err != nil {
				return err
			}
			if opts.JSONOutput {
				return output.PrintJSON(cmd.OutOrStdout(), map[string]interface{}{
					"purge_scheduled_at":            res.PurgeScheduledAt,
					"orphaned_organization_handles": res.OrphanedOrganizationHandles,
				})
			}
			fmt.Fprintf(cmd.OutOrStdout(), "Konto zur Löschung vorgemerkt (Endgültige Löschung: %s)\n", res.PurgeScheduledAt)
			return nil
		},
	}
	deleteCmd.Flags().BoolVar(&confirmYes, "yes", false, "Löschung ohne Rückfrage bestätigen")

	profileCmd.AddCommand(showCmd, updateCmd, passwordCmd, emailChangeCmd, deleteCmd)
	return profileCmd
}

// --- ORGANIZATION COMMANDS ---

func newOrgCmd(opts *Options) *cobra.Command {
	orgCmd := &cobra.Command{
		Use:   "org",
		Short: "Organisationen (Mandanten) verwalten",
	}

	listCmd := &cobra.Command{
		Use:   "list",
		Short: "Alle eigenen Organisationen auflisten",
		RunE: func(cmd *cobra.Command, args []string) error {
			cli, closeFn, _, err := resolveClient(opts)
			if err != nil {
				return err
			}
			defer closeFn()

			res, err := cli.ListMyOrganizations(context.Background(), &v1.ListMyOrganizationsRequest{})
			if err != nil {
				return err
			}
			return output.PrintOrganizationList(cmd.OutOrStdout(), res.Organizations, opts.JSONOutput)
		},
	}

	var (
		createHandle      string
		createFocus       string
		createDisplayName string
		createLegalName   string
	)
	createCmd := &cobra.Command{
		Use:   "create",
		Short: "Neue Organisation gründen",
		RunE: func(cmd *cobra.Command, args []string) error {
			if createHandle == "" {
				return fmt.Errorf("--handle is required")
			}
			focusEnum, err := parseFocusFlag(createFocus)
			if err != nil {
				return err
			}

			cli, closeFn, _, err := resolveClient(opts)
			if err != nil {
				return err
			}
			defer closeFn()

			req := &v1.CreateOrganizationRequest{
				Handle:       createHandle,
				PrimaryFocus: focusEnum,
			}
			if createDisplayName != "" {
				req.DisplayName = &createDisplayName
			}
			if createLegalName != "" {
				req.LegalName = &createLegalName
			}

			org, err := cli.CreateOrganization(context.Background(), req)
			if err != nil {
				return err
			}
			return output.PrintOrganization(cmd.OutOrStdout(), org, opts.JSONOutput)
		},
	}
	createCmd.Flags().StringVar(&createHandle, "handle", "", "Organisations-Handle")
	createCmd.Flags().StringVar(&createFocus, "focus", "", "Schwerpunkt: owner | manager | provider")
	createCmd.Flags().StringVar(&createDisplayName, "display-name", "", "Anzeigename")
	createCmd.Flags().StringVar(&createLegalName, "legal-name", "", "Offizieller Firmenname")

	showCmd := &cobra.Command{
		Use:   "show <id-or-handle>",
		Short: "Details einer Organisation anzeigen",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			cli, closeFn, _, err := resolveClient(opts)
			if err != nil {
				return err
			}
			defer closeFn()

			org, err := cli.GetOrganization(context.Background(), &v1.GetOrganizationRequest{
				IdOrHandle: args[0],
			})
			if err != nil {
				return err
			}
			return output.PrintOrganization(cmd.OutOrStdout(), org, opts.JSONOutput)
		},
	}

	var (
		updHandle       string
		updFocus        string
		updDisplayName  string
		updLegalName    string
		updLegalForm    string
		updStreet       string
		updPostalCode   string
		updCity         string
		updCountryCode  string
		updTaxID        string
		updVatID        string
		updContactEmail string
	)
	updateCmd := &cobra.Command{
		Use:   "update <id-or-handle>",
		Short: "Stammdaten einer Organisation aktualisieren",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			cli, closeFn, _, err := resolveClient(opts)
			if err != nil {
				return err
			}
			defer closeFn()

			req := &v1.UpdateOrganizationRequest{
				IdOrHandle: args[0],
			}
			if cmd.Flags().Changed("handle") {
				req.Handle = &updHandle
			}
			if cmd.Flags().Changed("focus") {
				f, err := parseFocusFlag(updFocus)
				if err != nil {
					return err
				}
				req.PrimaryFocus = &f
			}
			if cmd.Flags().Changed("display-name") {
				req.DisplayName = &updDisplayName
			}
			if cmd.Flags().Changed("legal-name") {
				req.LegalName = &updLegalName
			}
			if cmd.Flags().Changed("legal-form") {
				req.LegalForm = &updLegalForm
			}
			if cmd.Flags().Changed("street") {
				req.StreetAddress = &updStreet
			}
			if cmd.Flags().Changed("postal-code") {
				req.PostalCode = &updPostalCode
			}
			if cmd.Flags().Changed("city") {
				req.City = &updCity
			}
			if cmd.Flags().Changed("country-code") {
				req.CountryCode = &updCountryCode
			}
			if cmd.Flags().Changed("tax-id") {
				req.TaxId = &updTaxID
			}
			if cmd.Flags().Changed("vat-id") {
				req.VatId = &updVatID
			}
			if cmd.Flags().Changed("contact-email") {
				req.ContactEmail = &updContactEmail
			}

			org, err := cli.UpdateOrganization(context.Background(), req)
			if err != nil {
				return err
			}
			return output.PrintOrganization(cmd.OutOrStdout(), org, opts.JSONOutput)
		},
	}
	updateCmd.Flags().StringVar(&updHandle, "handle", "", "Neues Organisations-Handle")
	updateCmd.Flags().StringVar(&updFocus, "focus", "", "Schwerpunkt: owner | manager | provider")
	updateCmd.Flags().StringVar(&updDisplayName, "display-name", "", "Anzeigename")
	updateCmd.Flags().StringVar(&updLegalName, "legal-name", "", "Offizieller Firmenname")
	updateCmd.Flags().StringVar(&updLegalForm, "legal-form", "", "Rechtsform")
	updateCmd.Flags().StringVar(&updStreet, "street", "", "Straße und Hausnummer")
	updateCmd.Flags().StringVar(&updPostalCode, "postal-code", "", "Postleitzahl")
	updateCmd.Flags().StringVar(&updCity, "city", "", "Ort")
	updateCmd.Flags().StringVar(&updCountryCode, "country-code", "", "ISO Ländercode")
	updateCmd.Flags().StringVar(&updTaxID, "tax-id", "", "Steuernummer")
	updateCmd.Flags().StringVar(&updVatID, "vat-id", "", "USt-IdNr.")
	updateCmd.Flags().StringVar(&updContactEmail, "contact-email", "", "Kontakt-E-Mail")

	var orgDeleteYes bool
	deleteCmd := &cobra.Command{
		Use:   "delete <id-or-handle>",
		Short: "Organisation zur Löschung vormerken (60-Tage-Soft-Delete)",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			if !orgDeleteYes {
				return fmt.Errorf("bitte bestätigen Sie die Löschung mit --yes")
			}
			cli, closeFn, _, err := resolveClient(opts)
			if err != nil {
				return err
			}
			defer closeFn()

			org, err := cli.SoftDeleteOrganization(context.Background(), &v1.SoftDeleteOrganizationRequest{
				IdOrHandle: args[0],
			})
			if err != nil {
				return err
			}
			return output.PrintOrganization(cmd.OutOrStdout(), org, opts.JSONOutput)
		},
	}
	deleteCmd.Flags().BoolVar(&orgDeleteYes, "yes", false, "Löschung bestätigen")

	orgCmd.AddCommand(listCmd, createCmd, showCmd, updateCmd, deleteCmd)
	return orgCmd
}

func parseFocusFlag(val string) (v1.OrganizationFocus, error) {
	switch strings.ToLower(strings.TrimSpace(val)) {
	case "owner", "property_owner":
		return v1.OrganizationFocus_ORGANIZATION_FOCUS_PROPERTY_OWNER, nil
	case "manager", "property_manager":
		return v1.OrganizationFocus_ORGANIZATION_FOCUS_PROPERTY_MANAGER, nil
	case "provider", "service_provider":
		return v1.OrganizationFocus_ORGANIZATION_FOCUS_SERVICE_PROVIDER, nil
	default:
		return v1.OrganizationFocus_ORGANIZATION_FOCUS_UNSPECIFIED, fmt.Errorf("invalid --focus value %q (expected owner, manager, or provider)", val)
	}
}
