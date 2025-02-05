defmodule Tololo.MixProject do
  use Mix.Project

  def project do
    [
      app: :tololo,
      version: "1.0.12",
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: Mix.env() != :dev,
      aliases: aliases(),
      deps: deps(),
      preferred_cli_env: [
        "test.watch": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Tololo.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:ash_authentication, "~> 4.1"},
      {:ash_authentication_phoenix, "~> 2.0"},
      {:ash_graphql, "~> 1.5.0"},
      {:ash_phoenix, "~> 2.1.14"},
      {:ash_postgres, "~> 2.0"},
      {:ash, "~> 3.0"},
      {:igniter, "~> 0.5", only: [:dev, :test]},
      {:phoenix, "~> 1.7.18"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0.1"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:swoosh, "~> 1.5"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.5"},
      {:kafka_ex, "~> 0.11"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:prom_ex, "~> 1.11.0"},
      {:ex_doc, "~> 0.36", only: [:dev, :test], runtime: false},
      {:opentelemetry_exporter, "~> 1.8.0"},
      {:opentelemetry, "~> 1.5.0"},
      {:opentelemetry_api, "~> 1.4.0"},
      {:opentelemetry_ecto, "~> 1.2.0"},
      {:opentelemetry_phoenix, "~> 2.0.0"},
      {:opentelemetry_bandit, "~> 0.2.0"},
      {:picosat_elixir, "~> 0.2.0"},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ash_admin, "~> 0.12.6"},
      {:plug, "~> 1.16"},
      {:friendlyid, "~> 0.2.0"},
      {:req, "~> 0.5.0"},
      # Optional Enable Telegram Bot
      {:tololo_extension_telegram_bot,
       path:
         Path.join(["extensions", "telegram_bot"])
         |> Path.expand()},
      {:tololo_core,
       path:
         Path.join(["core"])
         |> Path.expand()}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ash.setup", "assets.setup", "assets.build", "run priv/repo/seeds.exs"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ash.setup --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind tololo", "esbuild tololo"],
      "assets.deploy": [
        "tailwind tololo --minify",
        "esbuild tololo --minify",
        "phx.digest"
      ]
    ]
  end
end
