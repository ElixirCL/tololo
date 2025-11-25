defmodule Eatsbot.Application do
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
      Eatsbot.Repo.config()
      |> Keyword.fetch!(:telemetry_prefix)
      |> OpentelemetryEcto.setup()

    extensions = Application.get_env(:eatsbot, :extensions, [])

    children =
      [
        EatsbotWeb.Telemetry,
        Eatsbot.Repo,
        {DNSCluster, query: Application.get_env(:eatsbot, :dns_cluster_query) || :ignore},
        {Phoenix.PubSub, name: Eatsbot.PubSub},
        # Start the Finch HTTP client for sending emails
        {Finch, name: Eatsbot.Finch},
        EatsbotWeb.Endpoint,
        {AshAuthentication.Supervisor, [otp_app: :eatsbot]},
        EatsbotCore.Deliveries.StaleCleaner,
        {Task, fn -> load_config() end}
      ] ++ extensions

    Eatsbot.GeocodingStore.init()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Eatsbot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EatsbotWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def load_config do
    %{latitude: lat, longitude: lng, name: name} =
      case EatsbotCore.Brands.Branch.read() do
        {:ok, branch_config} -> branch_config
        _ -> %{latitude: 0, longitude: 0, name: "A business"}
      end

    Application.put_env(:eatsbot, :from_location, {lat, lng})
    Application.put_env(:eatsbot, :business_name, name)
  end
end
