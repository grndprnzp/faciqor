defmodule Faciqor.Accounts.UserIdentity do
  use Ash.Resource,
    otp_app: :faciqor,
    domain: Faciqor.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication.UserIdentity]

  user_identity do
    user_resource Faciqor.Accounts.User
  end

  postgres do
    table "user_identities"
    repo Faciqor.Repo
  end
end
