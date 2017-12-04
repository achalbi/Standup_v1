# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :standup,
  ecto_repos: [Standup.Repo]

# Configures the endpoint
config :standup, StandupWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "gmQMLdAyuHKxYT18m88A+Lg11C0UDWO+Z0bjqHoLeP97I4Cl7qufqllNzOhHnMLH",
  render_errors: [view: StandupWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Standup.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configures the Ueberauth
config :ueberauth, Ueberauth,
  providers: [
    identity: { Ueberauth.Strategy.Identity, [
    callback_methods: ["POST"],
    uid_field: :email,
    nickname_field: :email,
#    request_path: "/auth/new",
#    callback_path: "/auth/identity/callback",
    ]},
    google: {Ueberauth.Strategy.Google, []},

  ]

# Ueberauth Strategy Config for Google oauth
config :ueberauth, Ueberauth.Strategy.Google.OAuth ,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET"),
  redirect_uri: System.get_env("GOOGLE_REDIRECT_URI")
  
# Guardian configuration
config :standup, Standup.Guardian,
  issuer: "standup",
  secret_key: System.get_env("GUARDIAN_SECRET") || "j6LyXGbyn1R15T9UzgWUmtlAGxRpnM6eMdSdmFR5SS3mpxpsPKPBrUfjnuynICgj",
  error_handler: Standup.AuthErrorHandler
  #serializer: Standup.GuardianSerializer

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
