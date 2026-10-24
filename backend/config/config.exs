import Config

config :faciqor,
  ash_domains: [
    Faciqor.Accounts
  ],
  ecto_repos: [Faciqor.Repo],
  generators: [timestamp_type: :utc_datetime_usec]

config :faciqor, Faciqor.Repo,
  migration_primary_key: [name: :id, type: :binary_id]

# Configures the endpoint
config :faciqor, FaciqorWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: FaciqorWeb.ErrorHTML, json: FaciqorWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Faciqor.PubSub,
  live_view: [signing_salt: "faciqor_salt_secret_12345"]

# Oban Configuration
config :faciqor, Oban,
  engine: Oban.Engines.Basic,
  queues: [default: 10],
  repo: Faciqor.Repo,
  plugins: [
    {Oban.Plugins.Cron,
     crontab: [
       {"@daily", Faciqor.Accounts.Workers.PurgeDeletedAccounts}
     ]}
  ]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
