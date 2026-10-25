package cmd

import (
	"context"
	"fmt"
	"regexp"
	"strconv"
	"strings"

	"faciqor/internal/config"
	"faciqor/internal/output"
	v1 "faciqor/pkg/api/v1"

	"github.com/spf13/cobra"
)

func resolveOperationsClient(opts *Options) (v1.OperationsServiceClient, func() error, *config.Config, error) {
	cfg, err := config.Load(opts.ConfigPath)
	if err != nil {
		return nil, nil, nil, err
	}
	endpoint := cfg.Endpoint
	if opts.EndpointFlag != "" {
		endpoint = opts.EndpointFlag
	}
	cli, closeFn, err := opts.OperationsClientFactory(endpoint, cfg.Token)
	if err != nil {
		return nil, nil, nil, err
	}
	return cli, closeFn, cfg, nil
}

// --- FACILITY COMMANDS ---

func newFacilityCmd(opts *Options) *cobra.Command {
	facilityCmd := &cobra.Command{
		Use:   "facility",
		Short: "Objekte und Liegenschaften einer Organisation verwalten",
	}

	var listOrg string
	var includeArchived bool
	listCmd := &cobra.Command{
		Use:   "list",
		Short: "Alle Objekte einer Organisation auflisten",
		RunE: func(cmd *cobra.Command, args []string) error {
			if listOrg == "" {
				return fmt.Errorf("--org ist erforderlich")
			}
			cli, closeFn, _, err := resolveOperationsClient(opts)
			if err != nil {
				return err
			}
			defer closeFn()

			res, err := cli.ListFacilities(context.Background(), &v1.ListFacilitiesRequest{
				OrgIdOrHandle:   strings.TrimPrefix(listOrg, "@"),
				IncludeArchived: includeArchived,
			})
			if err != nil {
				return err
			}
			return output.PrintFacilityList(cmd.OutOrStdout(), res.Facilities, opts.JSONOutput)
		},
	}
	listCmd.Flags().StringVar(&listOrg, "org", "", "Organisations-Handle oder UUID")
	listCmd.Flags().BoolVar(&includeArchived, "include-archived", false, "Archivierte Objekte einblenden")

	var showOrg string
	showCmd := &cobra.Command{
		Use:   "show <id-or-business-key>",
		Short: "Details eines Objekts anzeigen",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			if showOrg == "" {
				return fmt.Errorf("--org ist erforderlich")
			}
			cli, closeFn, _, err := resolveOperationsClient(opts)
			if err != nil {
				return err
			}
			defer closeFn()

			res, err := cli.GetFacility(context.Background(), &v1.GetFacilityRequest{
				OrgIdOrHandle:   strings.TrimPrefix(showOrg, "@"),
				IdOrBusinessKey: args[0],
			})
			if err != nil {
				return err
			}
			return output.PrintFacility(cmd.OutOrStdout(), res, opts.JSONOutput)
		},
	}
	showCmd.Flags().StringVar(&showOrg, "org", "", "Organisations-Handle oder UUID")

	var createOrg string
	var createAddresses []string
	var createRadius int32
	createCmd := &cobra.Command{
		Use:   "create",
		Short: "Neues Objekt anlegen",
		RunE: func(cmd *cobra.Command, args []string) error {
			if createOrg == "" {
				return fmt.Errorf("--org ist erforderlich")
			}
			if len(createAddresses) == 0 {
				return fmt.Errorf("mindestens eine --address Angabe ist erforderlich")
			}
			parsedAddrs, err := parseAddressFlags(createAddresses)
			if err != nil {
				return err
			}

			cli, closeFn, _, err := resolveOperationsClient(opts)
			if err != nil {
				return err
			}
			defer closeFn()

			req := &v1.CreateFacilityRequest{
				OrgIdOrHandle:        strings.TrimPrefix(createOrg, "@"),
				Addresses:            parsedAddrs,
				GeofenceRadiusMeters: &createRadius,
			}

			res, err := cli.CreateFacility(context.Background(), req)
			if err != nil {
				return err
			}
			return output.PrintFacility(cmd.OutOrStdout(), res, opts.JSONOutput)
		},
	}
	createCmd.Flags().StringVar(&createOrg, "org", "", "Organisations-Handle oder UUID")
	createCmd.Flags().StringArrayVar(&createAddresses, "address", nil, "Adresse oder Bereich (z.B. 'Hauptstraße 10-13, 10115 Berlin')")
	createCmd.Flags().Int32Var(&createRadius, "radius", 50, "Geofence-Radius in Metern")

	var updateOrg string
	var updateAddresses []string
	var updateRadius int32
	updateCmd := &cobra.Command{
		Use:   "update <id-or-business-key>",
		Short: "Teiladressen oder Geofence-Radius eines Objekts aktualisieren",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			if updateOrg == "" {
				return fmt.Errorf("--org ist erforderlich")
			}
			cli, closeFn, _, err := resolveOperationsClient(opts)
			if err != nil {
				return err
			}
			defer closeFn()

			req := &v1.UpdateFacilityRequest{
				OrgIdOrHandle:   strings.TrimPrefix(updateOrg, "@"),
				IdOrBusinessKey: args[0],
			}
			if len(updateAddresses) > 0 {
				parsedAddrs, err := parseAddressFlags(updateAddresses)
				if err != nil {
					return err
				}
				req.Addresses = parsedAddrs
			}
			if cmd.Flags().Changed("radius") {
				req.GeofenceRadiusMeters = &updateRadius
			}

			res, err := cli.UpdateFacility(context.Background(), req)
			if err != nil {
				return err
			}
			return output.PrintFacility(cmd.OutOrStdout(), res, opts.JSONOutput)
		},
	}
	updateCmd.Flags().StringVar(&updateOrg, "org", "", "Organisations-Handle oder UUID")
	updateCmd.Flags().StringArrayVar(&updateAddresses, "address", nil, "Aktualisierte Adresse(n)")
	updateCmd.Flags().Int32Var(&updateRadius, "radius", 50, "Neuer Geofence-Radius in Metern")

	var archiveOrg string
	archiveCmd := &cobra.Command{
		Use:   "archive <id-or-business-key>",
		Short: "Objekt archivieren",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			if archiveOrg == "" {
				return fmt.Errorf("--org ist erforderlich")
			}
			cli, closeFn, _, err := resolveOperationsClient(opts)
			if err != nil {
				return err
			}
			defer closeFn()

			res, err := cli.ArchiveFacility(context.Background(), &v1.ArchiveFacilityRequest{
				OrgIdOrHandle:   strings.TrimPrefix(archiveOrg, "@"),
				IdOrBusinessKey: args[0],
			})
			if err != nil {
				return err
			}
			return output.PrintFacility(cmd.OutOrStdout(), res, opts.JSONOutput)
		},
	}
	archiveCmd.Flags().StringVar(&archiveOrg, "org", "", "Organisations-Handle oder UUID")

	var unarchiveOrg string
	unarchiveCmd := &cobra.Command{
		Use:   "unarchive <id-or-business-key>",
		Short: "Archiviertes Objekt reaktivieren",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			if unarchiveOrg == "" {
				return fmt.Errorf("--org ist erforderlich")
			}
			cli, closeFn, _, err := resolveOperationsClient(opts)
			if err != nil {
				return err
			}
			defer closeFn()

			res, err := cli.UnarchiveFacility(context.Background(), &v1.UnarchiveFacilityRequest{
				OrgIdOrHandle:   strings.TrimPrefix(unarchiveOrg, "@"),
				IdOrBusinessKey: args[0],
			})
			if err != nil {
				return err
			}
			return output.PrintFacility(cmd.OutOrStdout(), res, opts.JSONOutput)
		},
	}
	unarchiveCmd.Flags().StringVar(&unarchiveOrg, "org", "", "Organisations-Handle oder UUID")

	var deleteOrg string
	var deleteYes bool
	deleteCmd := &cobra.Command{
		Use:   "delete <id-or-business-key>",
		Short: "Objekt vollständig löschen (nur für Owner)",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			if deleteOrg == "" {
				return fmt.Errorf("--org ist erforderlich")
			}
			if !deleteYes {
				return fmt.Errorf("bitte bestätigen Sie die Löschung mit --yes")
			}
			cli, closeFn, _, err := resolveOperationsClient(opts)
			if err != nil {
				return err
			}
			defer closeFn()

			res, err := cli.DeleteFacility(context.Background(), &v1.DeleteFacilityRequest{
				OrgIdOrHandle:   strings.TrimPrefix(deleteOrg, "@"),
				IdOrBusinessKey: args[0],
			})
			if err != nil {
				return err
			}
			if opts.JSONOutput {
				return output.PrintJSON(cmd.OutOrStdout(), map[string]bool{"deleted": res.Deleted})
			}
			fmt.Fprintln(cmd.OutOrStdout(), "Objekt erfolgreich gelöscht.")
			return nil
		},
	}
	deleteCmd.Flags().StringVar(&deleteOrg, "org", "", "Organisations-Handle oder UUID")
	deleteCmd.Flags().BoolVar(&deleteYes, "yes", false, "Löschung bestätigen")

	facilityCmd.AddCommand(listCmd, showCmd, createCmd, updateCmd, archiveCmd, unarchiveCmd, deleteCmd)
	return facilityCmd
}

// --- NUMBER RANGE COMMANDS ---

func newNumberRangeCmd(opts *Options) *cobra.Command {
	nrCmd := &cobra.Command{
		Use:   "number-range",
		Short: "Nummernkreise einer Organisation verwalten",
	}

	showCmd := &cobra.Command{
		Use:   "show <org-id-or-handle>",
		Short: "Aktuellen Nummernkreis einer Organisation anzeigen",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			cli, closeFn, _, err := resolveOperationsClient(opts)
			if err != nil {
				return err
			}
			defer closeFn()

			res, err := cli.GetNumberRange(context.Background(), &v1.GetNumberRangeRequest{
				OrgIdOrHandle: strings.TrimPrefix(args[0], "@"),
				EntityType:    v1.NumberRangeEntityType_NUMBER_RANGE_ENTITY_TYPE_FACILITY,
			})
			if err != nil {
				return err
			}
			return output.PrintNumberRange(cmd.OutOrStdout(), res, opts.JSONOutput)
		},
	}

	var prefix, suffix string
	var startVal, currentVal, stepVal int64
	updateCmd := &cobra.Command{
		Use:   "update <org-id-or-handle>",
		Short: "Nummernkreis einer Organisation aktualisieren (nur für Owner)",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			cli, closeFn, _, err := resolveOperationsClient(opts)
			if err != nil {
				return err
			}
			defer closeFn()

			req := &v1.UpdateNumberRangeRequest{
				OrgIdOrHandle: strings.TrimPrefix(args[0], "@"),
				EntityType:    v1.NumberRangeEntityType_NUMBER_RANGE_ENTITY_TYPE_FACILITY,
			}
			if cmd.Flags().Changed("prefix") {
				req.Prefix = &prefix
			}
			if cmd.Flags().Changed("start") {
				req.StartValue = &startVal
			}
			if cmd.Flags().Changed("current") {
				req.CurrentValue = &currentVal
			}
			if cmd.Flags().Changed("step") {
				req.Step = &stepVal
			}
			if cmd.Flags().Changed("suffix") {
				req.Suffix = &suffix
			}

			res, err := cli.UpdateNumberRange(context.Background(), req)
			if err != nil {
				return err
			}
			return output.PrintNumberRange(cmd.OutOrStdout(), res, opts.JSONOutput)
		},
	}
	updateCmd.Flags().StringVar(&prefix, "prefix", "", "Präfix (unterstützt {{Jahr}}, {{Monat}}, {{Tag}})")
	updateCmd.Flags().Int64Var(&startVal, "start", 1000, "Startwert")
	updateCmd.Flags().Int64Var(&currentVal, "current", 0, "Aktueller Wert")
	updateCmd.Flags().Int64Var(&stepVal, "step", 1, "Schrittweite")
	updateCmd.Flags().StringVar(&suffix, "suffix", "", "Suffix (unterstützt {{Jahr}}, {{Monat}}, {{Tag}})")

	nrCmd.AddCommand(showCmd, updateCmd)
	return nrCmd
}

// --- GEO PROVIDER COMMANDS ---

func newGeoProviderCmd(opts *Options) *cobra.Command {
	geoCmd := &cobra.Command{
		Use:   "geo-provider",
		Short: "Kartenanbieter und Geo-Suche einer Organisation konfigurieren",
	}

	showCmd := &cobra.Command{
		Use:   "show <org-id-or-handle>",
		Short: "Aktuelle Karten- und Geo-Provider-Konfiguration anzeigen",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			cli, closeFn, _, err := resolveOperationsClient(opts)
			if err != nil {
				return err
			}
			defer closeFn()

			res, err := cli.GetGeoProviderConfig(context.Background(), &v1.GetGeoProviderConfigRequest{
				OrgIdOrHandle: strings.TrimPrefix(args[0], "@"),
			})
			if err != nil {
				return err
			}
			return output.PrintGeoProviderConfig(cmd.OutOrStdout(), res, opts.JSONOutput)
		},
	}

	var mapProvStr, geoProvStr, hereKey string
	var applyAllOwned bool
	updateCmd := &cobra.Command{
		Use:   "update <org-id-or-handle>",
		Short: "Kartenanbieter und Geo-Suche aktualisieren (nur für Owner)",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			cli, closeFn, _, err := resolveOperationsClient(opts)
			if err != nil {
				return err
			}
			defer closeFn()

			req := &v1.UpdateGeoProviderConfigRequest{
				OrgIdOrHandle:       strings.TrimPrefix(args[0], "@"),
				ApplyToAllOwnedOrgs: applyAllOwned,
			}
			if cmd.Flags().Changed("map-provider") {
				mp, err := parseMapProviderFlag(mapProvStr)
				if err != nil {
					return err
				}
				req.MapProvider = &mp
			}
			if cmd.Flags().Changed("geocoding-provider") {
				gp, err := parseGeocodingProviderFlag(geoProvStr)
				if err != nil {
					return err
				}
				req.GeocodingProvider = &gp
			}
			if cmd.Flags().Changed("here-api-key") {
				req.HereApiKey = &hereKey
			}

			res, err := cli.UpdateGeoProviderConfig(context.Background(), req)
			if err != nil {
				return err
			}
			return output.PrintGeoProviderConfig(cmd.OutOrStdout(), res, opts.JSONOutput)
		},
	}
	updateCmd.Flags().StringVar(&mapProvStr, "map-provider", "", "Kartenanbieter: osm | openstreetmap | here")
	updateCmd.Flags().StringVar(&geoProvStr, "geocoding-provider", "", "Geo-Suche: nominatim | here")
	updateCmd.Flags().StringVar(&hereKey, "here-api-key", "", "HERE Maps API-Schlüssel")
	updateCmd.Flags().BoolVar(&applyAllOwned, "apply-all-owned", false, "Für alle Organisationen übernehmen, in denen ich Owner bin")

	geoCmd.AddCommand(showCmd, updateCmd)
	return geoCmd
}

func parseMapProviderFlag(val string) (v1.MapProvider, error) {
	switch strings.ToLower(strings.TrimSpace(val)) {
	case "osm", "openstreetmap":
		return v1.MapProvider_MAP_PROVIDER_OPENSTREETMAP, nil
	case "here":
		return v1.MapProvider_MAP_PROVIDER_HERE, nil
	default:
		return v1.MapProvider_MAP_PROVIDER_UNSPECIFIED, fmt.Errorf("ungültiger --map-provider '%s' (erlaubt: osm, here)", val)
	}
}

func parseGeocodingProviderFlag(val string) (v1.GeocodingProvider, error) {
	switch strings.ToLower(strings.TrimSpace(val)) {
	case "nominatim", "osm":
		return v1.GeocodingProvider_GEOCODING_PROVIDER_NOMINATIM, nil
	case "here":
		return v1.GeocodingProvider_GEOCODING_PROVIDER_HERE, nil
	default:
		return v1.GeocodingProvider_GEOCODING_PROVIDER_UNSPECIFIED, fmt.Errorf("ungültiger --geocoding-provider '%s' (erlaubt: nominatim, here)", val)
	}
}

var (
	reGermanRange  = regexp.MustCompile(`^(.+?)\s+(\d+)\s*-\s*(\d+)$`)
	reGermanSingle = regexp.MustCompile(`^(.+?)\s+(\d+[a-zA-Z]?)$`)
	reUSSingle     = regexp.MustCompile(`^(\d+[a-zA-Z]?)\s+([a-zA-Z].+)$`)
	reZipCity      = regexp.MustCompile(`^(\d{4,5})\s+(.+)$`)
)

func parseAddressFlags(rawFlags []string) ([]*v1.FacilityAddressInput, error) {
	var out []*v1.FacilityAddressInput

	for _, raw := range rawFlags {
		parts := strings.SplitN(raw, ",", 2)
		streetBlock := strings.TrimSpace(parts[0])
		postalCode := "10115"
		city := "Berlin"

		if len(parts) > 1 {
			tail := strings.TrimSpace(parts[1])
			if m := reZipCity.FindStringSubmatch(tail); m != nil {
				postalCode = m[1]
				city = strings.TrimSpace(m[2])
			} else if tail != "" {
				city = tail
			}
		}

		cornerSegments := strings.Split(streetBlock, "/")
		for _, seg := range cornerSegments {
			seg = strings.TrimSpace(seg)
			if seg == "" {
				continue
			}

			if m := reGermanRange.FindStringSubmatch(seg); m != nil {
				street := strings.TrimSpace(m[1])
				startNum, _ := strconv.Atoi(m[2])
				endNum, _ := strconv.Atoi(m[3])
				if endNum < startNum || endNum-startNum > 100 {
					return nil, fmt.Errorf("ungültiger Hausnummern-Bereich in '%s'", seg)
				}
				for n := startNum; n <= endNum; n++ {
					isPrim := len(out) == 0
					out = append(out, &v1.FacilityAddressInput{
						Street:      street,
						HouseNumber: strconv.Itoa(n),
						PostalCode:  postalCode,
						City:        city,
						IsPrimary:   &isPrim,
					})
				}
			} else if m := reUSSingle.FindStringSubmatch(seg); m != nil {
				isPrim := len(out) == 0
				out = append(out, &v1.FacilityAddressInput{
					Street:      strings.TrimSpace(m[2]),
					HouseNumber: strings.TrimSpace(m[1]),
					PostalCode:  postalCode,
					City:        city,
					IsPrimary:   &isPrim,
				})
			} else if m := reGermanSingle.FindStringSubmatch(seg); m != nil {
				isPrim := len(out) == 0
				out = append(out, &v1.FacilityAddressInput{
					Street:      strings.TrimSpace(m[1]),
					HouseNumber: strings.TrimSpace(m[2]),
					PostalCode:  postalCode,
					City:        city,
					IsPrimary:   &isPrim,
				})
			} else {
				return nil, fmt.Errorf("Adresse '%s' muss Straße und Hausnummer enthalten", seg)
			}
		}
	}

	return out, nil
}
