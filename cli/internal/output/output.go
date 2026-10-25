package output

import (
	"encoding/json"
	"fmt"
	"io"
	"text/tabwriter"

	v1 "faciqor/pkg/api/v1"
)

func PrintJSON(w io.Writer, data interface{}) error {
	enc := json.NewEncoder(w)
	enc.SetIndent("", "  ")
	return enc.Encode(data)
}

func PrintProfile(w io.Writer, profile *v1.UserProfileResponse, asJSON bool) error {
	if asJSON {
		m := map[string]interface{}{
			"id":             profile.Id,
			"email":          profile.Email,
			"handle":         profile.Handle,
			"display_name":   profile.DisplayName,
			"first_name":     profile.FirstName,
			"last_name":      profile.LastName,
			"phone":          profile.Phone,
			"timezone":       profile.Timezone,
			"locale":         profile.Locale,
			"email_verified": profile.EmailVerified,
			"inserted_at":    profile.InsertedAt,
		}
		if profile.PendingEmail != nil {
			m["pending_email"] = *profile.PendingEmail
		}
		if profile.AvatarUrl != nil {
			m["avatar_url"] = *profile.AvatarUrl
		}
		return PrintJSON(w, m)
	}

	tw := tabwriter.NewWriter(w, 0, 0, 2, ' ', 0)
	fmt.Fprintf(tw, "ID:\t%s\n", profile.Id)
	fmt.Fprintf(tw, "HANDLE:\t@%s\n", profile.Handle)
	if profile.DisplayName != "" {
		fmt.Fprintf(tw, "DISPLAY NAME:\t%s\n", profile.DisplayName)
	}
	if profile.FirstName != "" || profile.LastName != "" {
		fmt.Fprintf(tw, "NAME:\t%s %s\n", profile.FirstName, profile.LastName)
	}
	fmt.Fprintf(tw, "EMAIL:\t%s\n", profile.Email)
	if profile.PendingEmail != nil && *profile.PendingEmail != "" {
		fmt.Fprintf(tw, "PENDING EMAIL:\t%s (Wartet auf Bestätigung)\n", *profile.PendingEmail)
	}
	if profile.Phone != "" {
		fmt.Fprintf(tw, "PHONE:\t%s\n", profile.Phone)
	}
	fmt.Fprintf(tw, "TIMEZONE:\t%s\n", profile.Timezone)
	fmt.Fprintf(tw, "LOCALE:\t%s\n", profile.Locale)
	fmt.Fprintf(tw, "VERIFIED:\t%v\n", profile.EmailVerified)
	if profile.AvatarUrl != nil && *profile.AvatarUrl != "" {
		fmt.Fprintf(tw, "AVATAR URL:\t%s\n", *profile.AvatarUrl)
	}
	fmt.Fprintf(tw, "CREATED:\t%s\n", profile.InsertedAt)
	return tw.Flush()
}

func PrintApiTokens(w io.Writer, tokens []*v1.ApiTokenInfo, asJSON bool) error {
	if asJSON {
		return PrintJSON(w, tokens)
	}

	tw := tabwriter.NewWriter(w, 0, 0, 2, ' ', 0)
	fmt.Fprintln(tw, "ID\tNAME\tPREFIX\tSCOPES\tCREATED\tEXPIRES\tLAST USED")
	for _, t := range tokens {
		expires := "Unbegrenzt"
		if t.ExpiresAt != nil && *t.ExpiresAt != "" {
			expires = *t.ExpiresAt
		}
		lastUsed := "Nie"
		if t.LastUsedAt != nil && *t.LastUsedAt != "" {
			lastUsed = *t.LastUsedAt
		}
		statusSuffix := ""
		if t.RevokedAt != nil && *t.RevokedAt != "" {
			statusSuffix = " [WIDERRUFEN]"
		}
		fmt.Fprintf(tw, "%s\t%s%s\t%s\t%s\t%s\t%s\t%s\n",
			t.Id, t.Name, statusSuffix, t.TokenPrefix+"****", t.Scopes, t.InsertedAt, expires, lastUsed)
	}
	return tw.Flush()
}

func PrintOrganization(w io.Writer, org *v1.OrganizationResponse, asJSON bool) error {
	if asJSON {
		return PrintJSON(w, orgToMap(org))
	}

	tw := tabwriter.NewWriter(w, 0, 0, 2, ' ', 0)
	fmt.Fprintf(tw, "ID:\t%s\n", org.Id)
	fmt.Fprintf(tw, "HANDLE:\t@%s\n", org.Handle)
	fmt.Fprintf(tw, "FOCUS:\t%s\n", org.PrimaryFocus.String())
	fmt.Fprintf(tw, "MY ROLE:\t%s\n", org.MyRole.String())
	fmt.Fprintf(tw, "DISPLAY NAME:\t%s\n", org.DisplayName)
	fmt.Fprintf(tw, "LEGAL NAME:\t%s\n", org.LegalName)
	fmt.Fprintf(tw, "LEGAL FORM:\t%s\n", org.LegalForm)
	fmt.Fprintf(tw, "ADDRESS:\t%s, %s %s (%s)\n", org.StreetAddress, org.PostalCode, org.City, org.CountryCode)
	fmt.Fprintf(tw, "TAX ID:\t%s\n", org.TaxId)
	fmt.Fprintf(tw, "VAT ID:\t%s\n", org.VatId)
	fmt.Fprintf(tw, "CONTACT EMAIL:\t%s\n", org.ContactEmail)
	if org.LogoUrl != nil && *org.LogoUrl != "" {
		fmt.Fprintf(tw, "LOGO URL:\t%s\n", *org.LogoUrl)
	}
	if org.DeletedAt != nil {
		fmt.Fprintf(tw, "DELETED AT:\t%s\n", *org.DeletedAt)
	}
	return tw.Flush()
}

func PrintOrganizationList(w io.Writer, orgs []*v1.OrganizationResponse, asJSON bool) error {
	if asJSON {
		items := make([]map[string]interface{}, 0, len(orgs))
		for _, o := range orgs {
			items = append(items, orgToMap(o))
		}
		return PrintJSON(w, items)
	}

	tw := tabwriter.NewWriter(w, 0, 0, 2, ' ', 0)
	fmt.Fprintln(tw, "ID\tHANDLE\tFOCUS\tROLE\tLEGAL NAME")
	for _, o := range orgs {
		fmt.Fprintf(tw, "%s\t@%s\t%s\t%s\t%s\n",
			o.Id, o.Handle, o.PrimaryFocus.String(), o.MyRole.String(), o.LegalName)
	}
	return tw.Flush()
}

func orgToMap(org *v1.OrganizationResponse) map[string]interface{} {
	m := map[string]interface{}{
		"id":             org.Id,
		"handle":         org.Handle,
		"primary_focus":  org.PrimaryFocus.String(),
		"my_role":        org.MyRole.String(),
		"display_name":   org.DisplayName,
		"legal_name":     org.LegalName,
		"legal_form":     org.LegalForm,
		"street_address": org.StreetAddress,
		"postal_code":    org.PostalCode,
		"city":           org.City,
		"country_code":   org.CountryCode,
		"tax_id":         org.TaxId,
		"vat_id":         org.VatId,
		"contact_email":  org.ContactEmail,
	}
	if org.LogoUrl != nil {
		m["logo_url"] = *org.LogoUrl
	}
	if org.DeletedAt != nil {
		m["deleted_at"] = *org.DeletedAt
	}
	return m
}

func PrintFacility(w io.Writer, f *v1.FacilityResponse, asJSON bool) error {
	if asJSON {
		return PrintJSON(w, facilityToMap(f))
	}

	tw := tabwriter.NewWriter(w, 0, 0, 2, ' ', 0)
	fmt.Fprintf(tw, "ID:\t%s\n", f.Id)
	fmt.Fprintf(tw, "BUSINESS KEY:\t%s\n", f.BusinessKey)
	fmt.Fprintf(tw, "TITLE:\t%s\n", f.Title)
	fmt.Fprintf(tw, "GEOFENCE RADIUS:\t%dm (%d Eckpunkte)\n", f.GeofenceRadiusMeters, len(f.GeofencePolygon))
	if f.ArchivedAt != nil && *f.ArchivedAt != "" {
		fmt.Fprintf(tw, "ARCHIVED AT:\t%s\n", *f.ArchivedAt)
	}
	fmt.Fprintf(tw, "ADDRESSES:\t%d\n", len(f.Addresses))
	for _, a := range f.Addresses {
		prim := ""
		if a.IsPrimary {
			prim = " [PRIMARY]"
		}
		fmt.Fprintf(tw, "  - %s %s, %s %s (%s)\tLat: %s, Lon: %s%s\n",
			a.Street, a.HouseNumber, a.PostalCode, a.City, a.CountryCode, a.Latitude, a.Longitude, prim)
	}
	return tw.Flush()
}

func PrintFacilityList(w io.Writer, facilities []*v1.FacilityResponse, asJSON bool) error {
	if asJSON {
		items := make([]map[string]interface{}, 0, len(facilities))
		for _, f := range facilities {
			items = append(items, facilityToMap(f))
		}
		return PrintJSON(w, items)
	}

	tw := tabwriter.NewWriter(w, 0, 0, 2, ' ', 0)
	fmt.Fprintln(tw, "ID\tBUSINESS KEY\tTITLE\tADDRESSES\tSTATUS")
	for _, f := range facilities {
		status := "ACTIVE"
		if f.ArchivedAt != nil && *f.ArchivedAt != "" {
			status = "ARCHIVED"
		}
		fmt.Fprintf(tw, "%s\t%s\t%s\t%d\t%s\n",
			f.Id, f.BusinessKey, f.Title, len(f.Addresses), status)
	}
	return tw.Flush()
}

func facilityToMap(f *v1.FacilityResponse) map[string]interface{} {
	addrs := make([]map[string]interface{}, 0, len(f.Addresses))
	for _, a := range f.Addresses {
		addrs = append(addrs, map[string]interface{}{
			"id":           a.Id,
			"street":       a.Street,
			"house_number": a.HouseNumber,
			"postal_code":  a.PostalCode,
			"city":         a.City,
			"country_code": a.CountryCode,
			"latitude":     a.Latitude,
			"longitude":    a.Longitude,
			"is_primary":   a.IsPrimary,
			"sort_order":   a.SortOrder,
		})
	}
	m := map[string]interface{}{
		"id":                     f.Id,
		"organization_id":        f.OrganizationId,
		"business_key":           f.BusinessKey,
		"title":                  f.Title,
		"addresses":              addrs,
		"geofence_radius_meters": f.GeofenceRadiusMeters,
		"inserted_at":            f.InsertedAt,
		"updated_at":             f.UpdatedAt,
	}
	if f.ArchivedAt != nil {
		m["archived_at"] = *f.ArchivedAt
	}
	return m
}

func PrintNumberRange(w io.Writer, nr *v1.NumberRangeResponse, asJSON bool) error {
	if asJSON {
		m := map[string]interface{}{
			"id":               nr.Id,
			"organization_id":  nr.OrganizationId,
			"entity_type":      nr.EntityType.String(),
			"prefix":           nr.Prefix,
			"start_value":      nr.StartValue,
			"step":             nr.Step,
			"suffix":           nr.Suffix,
			"preview_next_key": nr.PreviewNextKey,
		}
		if nr.CurrentValue != nil {
			m["current_value"] = *nr.CurrentValue
		}
		return PrintJSON(w, m)
	}

	tw := tabwriter.NewWriter(w, 0, 0, 2, ' ', 0)
	fmt.Fprintf(tw, "PREFIX:\t%s\n", nr.Prefix)
	fmt.Fprintf(tw, "START VALUE:\t%d\n", nr.StartValue)
	if nr.CurrentValue != nil {
		fmt.Fprintf(tw, "CURRENT VALUE:\t%d\n", *nr.CurrentValue)
	} else {
		fmt.Fprintf(tw, "CURRENT VALUE:\t(noch nicht vergeben)\n")
	}
	fmt.Fprintf(tw, "STEP:\t%d\n", nr.Step)
	fmt.Fprintf(tw, "SUFFIX:\t%s\n", nr.Suffix)
	fmt.Fprintf(tw, "NEXT BUSINESS KEY:\t%s\n", nr.PreviewNextKey)
	return tw.Flush()
}

func PrintGeoProviderConfig(w io.Writer, cfg *v1.GeoProviderConfigResponse, asJSON bool) error {
	if asJSON {
		return PrintJSON(w, map[string]interface{}{
			"organization_id":              cfg.OrganizationId,
			"organization_handle":          cfg.OrganizationHandle,
			"map_provider":                 cfg.MapProvider.String(),
			"geocoding_provider":           cfg.GeocodingProvider.String(),
			"has_here_api_key":             cfg.HasHereApiKey,
			"updated_organization_handles": cfg.UpdatedOrganizationHandles,
		})
	}

	tw := tabwriter.NewWriter(w, 0, 0, 2, ' ', 0)
	fmt.Fprintf(tw, "ORGANIZATION:\t@%s\n", cfg.OrganizationHandle)
	fmt.Fprintf(tw, "MAP PROVIDER:\t%s\n", cfg.MapProvider.String())
	fmt.Fprintf(tw, "GEOCODING PROVIDER:\t%s\n", cfg.GeocodingProvider.String())
	fmt.Fprintf(tw, "HERE API KEY SET:\t%v\n", cfg.HasHereApiKey)
	return tw.Flush()
}
