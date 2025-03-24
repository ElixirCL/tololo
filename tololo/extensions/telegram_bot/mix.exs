defmodule Tololo.Extensions.TelegramBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :tololo_extension_telegram_bot,
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
      {:telegex, "~> 1.8.0"},
      {:finch, "~> 0.13"},
      {:multipart, "~> 0.4.0"},
      {:remote_ip, "~> 1.2"},
      {:ash_authentication, "~> 4.1"},
      {:ash_authentication_phoenix, "~> 2.0"},
      {:ash_graphql, "~> 1.7.3"},
      {:ash_phoenix, "~> 2.1.14"},
      {:ash_postgres, "~> 2.0"},
      {:ash, "~> 3.0"},
      {:ash_admin, "~> 0.12.6"},
      {:phoenix, "~> 1.7.18"},
      {:tololo_core,
       path:
         Path.join(["..", "..", "core"])
         |> Path.expand()},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end
end
