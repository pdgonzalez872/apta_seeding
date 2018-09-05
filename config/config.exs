# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :apta_seeding,
  ecto_repos: [AptaSeeding.Repo]

# Configures the endpoint
config :apta_seeding, AptaSeedingWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Y85bfur68wppNISNeIBK13V+lGs6445GH7P9zz0V6wncGiEjD+8DwuszoRWh4n9x",
  render_errors: [view: AptaSeedingWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: AptaSeeding.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
