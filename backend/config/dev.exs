import Config

config :faciqor, Faciqor.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "faciqor_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :faciqor, FaciqorWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "dev_secret_key_base_at_least_64_bytes_long_for_faciqor_local_development_only_1234567890",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ],
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/faciqor_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

config :faciqor, :token_signing_secret, "dev_token_signing_secret_at_least_32_bytes_long_1234567890"

config :ex_aws,
  access_key_id: "any",
  secret_access_key: "any",
  region: "us-east-1"

config :ex_aws, :s3,
  scheme: "http://",
  host: "localhost",
  port: 8333

config :logger, :console, format: "[$level] $message\n"
config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime
