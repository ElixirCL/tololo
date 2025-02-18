defmodule Tololo.Extensions.Prometheus.MixProject do
  use Mix.Project

  def project do
    [
      app: :tololo_extension_prometheus,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:phoenix, "~> 1.7.18"},
      {:prom_ex, "~> 1.11.0"},
      {:tololo_core,
       path:
         Path.join(["..", "..", "core"])
         |> Path.expand()}
    ]
  end
end
