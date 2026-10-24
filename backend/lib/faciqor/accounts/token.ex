defmodule Faciqor.Accounts.Token do
  use Ash.Resource,
    otp_app: :faciqor,
    domain: Faciqor.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication.TokenResource]

  postgres do
    table "user_tokens"
    repo Faciqor.Repo
  end
end
