defmodule Faciqor.Geo.Provider do
  @moduledoc """
  Abstraktes Verhalten (Behaviour) für Geo-Such- und Geocoding-Provider.
  Der funktionale Kern (`Faciqor.Operations`) kommuniziert ausschließlich über diese Abstraktion.
  """

  alias Faciqor.Geo.AddressCandidate

  @callback search(query :: String.t(), opts :: keyword()) ::
              {:ok, [AddressCandidate.t()]} | {:error, term()}
end
