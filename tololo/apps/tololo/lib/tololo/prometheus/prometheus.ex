defmodule Tololo.Prometheus do
  @moduledoc """
  PromEx module, handles integration with Prometheus.
  """

  use PromEx, otp_app: :tololo

  alias PromEx.Plugins

  @impl true
  def plugins do
    [
      # PromEx built in plugins
      Plugins.Application,
      Plugins.Beam,
      {Plugins.Phoenix, router: TololoWeb.Router, endpoint: TololoWeb.Endpoint},
      Plugins.Ecto,
      Plugins.PhoenixLiveView

      # Add your own PromEx metrics plugins
      # Tololo.Users.PromExPlugin
      # TODO: implement plugin for metrics described in https://github.com/ElixirCL/tololo/issues/1#issuecomment-2582911263
    ]
  end

  @impl true
  def dashboard_assigns do
    [
      datasource_id: "prometheus",
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
      {:prom_ex, "phoenix_live_view.json"}

      # Add your dashboard definitions here with the format: {:otp_app, "path_in_priv"}
      # {:tololo, "/grafana_dashboards/user_metrics.json"}
      # TODO: add dashboards for custom Tololo metrics
    ]
  end
end
