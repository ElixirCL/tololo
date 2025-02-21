defmodule Tololo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    if System.get_env("ECTO_IPV6") do
      :httpc.set_option(:ipfamily, :inet6fb4)
    end

    :ok = OpentelemetryBandit.setup()
    :ok = OpentelemetryPhoenix.setup(adapter: :bandit)

    :ok =
      Tololo.Repo.config()
      |> Keyword.fetch!(:telemetry_prefix)
      |> OpentelemetryEcto.setup()

    extensions = Application.get_env(:tololo, :extensions, [])

    children =
      [
        TololoWeb.Telemetry,
        Tololo.Repo,
        {DNSCluster, query: Application.get_env(:tololo, :dns_cluster_query) || :ignore},
        {Phoenix.PubSub, name: Tololo.PubSub},
        # Start the Finch HTTP client for sending emails
        {Finch, name: Tololo.Finch},
        TololoWeb.Endpoint,
        {AshAuthentication.Supervisor, [otp_app: :tololo]},
        TololoCore.Deliveries.StaleCleaner
      ] ++ extensions

    Tololo.GeocodingStore.init()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tololo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TololoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
