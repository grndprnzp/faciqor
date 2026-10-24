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
		return PrintJSON(w, map[string]interface{}{
			"id":             profile.Id,
			"email":          profile.Email,
			"handle":         profile.Handle,
			"email_verified": profile.EmailVerified,
			"inserted_at":    profile.InsertedAt,
		})
	}

	tw := tabwriter.NewWriter(w, 0, 0, 2, ' ', 0)
	fmt.Fprintf(tw, "ID:\t%s\n", profile.Id)
	fmt.Fprintf(tw, "HANDLE:\t@%s\n", profile.Handle)
	fmt.Fprintf(tw, "EMAIL:\t%s\n", profile.Email)
	fmt.Fprintf(tw, "VERIFIED:\t%v\n", profile.EmailVerified)
	fmt.Fprintf(tw, "CREATED:\t%s\n", profile.InsertedAt)
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
	if org.DeletedAt != nil {
		m["deleted_at"] = *org.DeletedAt
	}
	return m
}
