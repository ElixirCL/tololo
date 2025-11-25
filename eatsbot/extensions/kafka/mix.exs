defmodule Eatsbot.Extensions.Kafka.MixProject do
  use Mix.Project

  def project do
    [
      app: :eatsbot_extension_kafka,
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
      {:kafka_ex, "~> 0.11", runtime: false},
      {:eatsbot_core,
       path:
         Path.join(["..", "..", "core"])
         |> Path.expand()}
    ]
  end
end
