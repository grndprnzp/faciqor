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
