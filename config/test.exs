use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :apta_seeding, AptaSeedingWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :apta_seeding, AptaSeeding.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "apta_seeding_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  ownership_timeout: 10 * 60 * 1000
