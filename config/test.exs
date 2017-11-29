use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :standup, StandupWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :standup, Standup.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "standup_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Configuration for Comeonin
config :bcrypt_elixir, :log_rounds, 4