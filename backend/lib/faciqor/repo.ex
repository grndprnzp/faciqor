defmodule Faciqor.Repo do
  use AshPostgres.Repo,
    otp_app: :faciqor

  def installed_extensions do
    ["uuid-ossp", "citext"]
  end
end
