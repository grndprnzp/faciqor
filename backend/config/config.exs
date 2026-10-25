import Config

config :faciqor,
  ash_domains: [
    Faciqor.Accounts,
    Faciqor.Media
  ],
  ecto_repos: [Faciqor.Repo],
  generators: [timestamp_type: :utc_datetime_usec]

config :faciqor, :media,
  public_bucket: "faciqor-public",
  vault_bucket: "faciqor-vault",
  public_base_url: "http://localhost:8333/faciqor-public"

config :ash,
  default_string_length_count: :codepoints

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

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.3.0",
  default: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.0",
  default: [
    args: ~w(
      js/app.js
      --bundle
      --target=es2020
      --outdir=../priv/static/assets/js
      --external:/fonts/*
      --external:/images/*
    ),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

import_config "#{config_env()}.exs"
