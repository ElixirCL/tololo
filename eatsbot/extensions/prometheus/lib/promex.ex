defmodule Eatsbot.Extensions.Prometheus.PromEx do
  @moduledoc """
  PromEx module, handles integration with Prometheus.
  """

  use PromEx, otp_app: :eatsbot

  alias PromEx.Plugins

  @impl true
  def plugins do
    [
      # PromEx built in plugins
      Plugins.Application,
      Plugins.Beam,
      {Plugins.Phoenix, router: EatsbotWeb.Router, endpoint: EatsbotWeb.Endpoint},
      Plugins.Ecto,
      Plugins.PhoenixLiveView,
      Eatsbot.Extensions.Prometheus.PromExPlugin
    ]
  end

  @impl true
  def dashboard_assigns do
    [
      datasource_id: "prometheus-eatsbot",
      default_selected_interval: "30s"
    ]
  end

  @impl true
  def dashboards do
    [
      # PromEx built in Grafana dashboards
      {:prom_ex, "application.json"},
      {:prom_ex, "beam.json"},
      {:prom_ex, "phoenix.json"},
      {:prom_ex, "ecto.json"},
      {:prom_ex, "phoenix_live_view.json"},

      {:eatsbot_extension_prometheus, "/dashboards/deliveries.json"}
    ]
  end
end
