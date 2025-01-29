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

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
       {:telegex, "~> 1.8.0", runtime: false},
       {:finch, "~> 0.13"},
       {:multipart, "~> 0.4.0"},
       {:remote_ip, "~> 1.2"},
    ]
  end
end
