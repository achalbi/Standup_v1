defmodule Standup.Mixfile do
  use Mix.Project

  def project do
    [
      app: :standup,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Standup.Application, []},
      extra_applications: [:logger, :runtime_tools, :ueberauth, :ueberauth_google, :ueberauth_identity, :cloudex, :arc_ecto, :timex, :elixir_google_spreadsheets]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10.5"},
      {:phoenix_live_reload, "~> 1.1"},
      {:gettext, "~> 0.11"},
      {:ueberauth, "~> 0.4"},
      {:ueberauth_identity, "~> 0.2"},
      {:ueberauth_google, "~> 0.7"},
      {:cowboy, "~> 1.0"},
      {:guardian, "~> 1.0"},
      {:comeonin, "~> 4.0"},
      {:bcrypt_elixir, "~> 1.0"},
      {:cloudex, "~> 1.0.0"},
      {:arc, "~> 0.8.0"},
      {:arc_ecto, "~> 0.7.0"},
      {:elixir_google_spreadsheets, "~> 0.1.9"},
      {:ecto_gss, "~> 0.1"},
      {:json_web_token, git: "https://github.com/starbuildr/json_web_token_ex.git", override: true},
      {:timex, "~> 3.1"},
      {:sphinx, "~> 0.1.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
