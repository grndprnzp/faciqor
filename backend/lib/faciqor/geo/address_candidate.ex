defmodule Faciqor.Geo.AddressCandidate do
  @moduledoc """
  Provider-unabhängige Domänenstruktur für ein Geocoding-/Adresssuchergebnis.
  Koordinaten werden gemäß AGENTS.md § 5.1 strikt als `Decimal` geführt.
  """

  @enforce_keys [
    :street,
    :house_number,
    :postal_code,
    :city,
    :country_code,
    :latitude,
    :longitude
  ]
  defstruct [
    :provider_place_id,
    :formatted_label,
    :street,
    :house_number,
    :postal_code,
    :city,
    :country_code,
    :latitude,
    :longitude
  ]

  @type t :: %__MODULE__{
          provider_place_id: String.t() | nil,
          formatted_label: String.t() | nil,
          street: String.t(),
          house_number: String.t(),
          postal_code: String.t(),
          city: String.t(),
          country_code: String.t(),
          latitude: Decimal.t(),
          longitude: Decimal.t()
        }
end
