defmodule TololoCore.MixProject do
  use Mix.Project

  def project do
    [
      app: :tololo_core,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: Mix.env() != :dev,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ash_money, "~> 0.1"},
      {:igniter, "~> 0.5", only: [:dev, :test]},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:ash_authentication, "~> 4.1"},
      {:ash_authentication_phoenix, "~> 2.0"},
      {:ash_graphql, "~> 1.5.0"},
      {:ash_phoenix, "~> 2.1.14"},
      {:ash_postgres, "~> 2.0"},
      {:ash, "~> 3.0"},
      {:ash_admin, "~> 0.12.6"},
      {:ex_cldr, "~> 2.0"},
      {:ex_cldr_numbers, "~> 2.33"},
      {:ex_cldr_currencies, "~> 2.16"},
      {:ex_cldr_dates_times, "~> 2.20"},
      {:ex_cldr_calendars, "~> 1.26"},
      {:ex_cldr_lists, "~> 2.11"},
      {:ex_cldr_messages, "~> 1.0"},
      {:ex_cldr_units, "~> 3.17"},
      {:gettext, "~> 0.26"},
      {:picosat_elixir, "~> 0.2.0"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end
end
