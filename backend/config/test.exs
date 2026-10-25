import Config

config :faciqor, Faciqor.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "faciqor_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

config :faciqor, FaciqorWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "test_secret_key_base_at_least_64_bytes_long_for_faciqor_automated_testing_only_1234567890",
  server: false

config :faciqor, :token_signing_secret, "test_token_signing_secret_at_least_32_bytes_long_1234567890"

config :faciqor, Oban, testing: :manual
config :faciqor, :geo_provider_adapter, Faciqor.Geo.Providers.Mock

config :ex_aws,
  access_key_id: "test",
  secret_access_key: "test",
  region: "us-east-1"

config :ex_aws, :s3,
  scheme: "http://",
  host: "localhost",
  port: 8333

config :logger, level: :warning
config :phoenix, :plug_init_mode, :runtime
