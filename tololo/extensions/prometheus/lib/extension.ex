defmodule Tololo.Extensions.Prometheus do
  @moduledoc false
  use Supervisor
  @behaviour TololoCore.Extension

  @impl true
  def child_spec(init_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [init_arg]},
      type: :supervisor,
      restart: :permanent
    }
  end

  def start_link(_init_arg) do
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    children = [
      Tololo.Extensions.Prometheus.PromEx
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end

  @impl true
  def routes() do
    quote do
    end
  end

  @impl true
  def endpoint() do
    quote do
      plug PromEx.Plug, prom_ex_module: Tololo.Extensions.Prometheus.PromEx
    end
  end

  @impl true
  def ash_domains(), do: []
end
