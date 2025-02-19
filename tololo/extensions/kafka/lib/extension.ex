defmodule Tololo.Extensions.Kafka do
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
    Application.put_env(:tololo, :kafka_driver, Tololo.Extensions.Kafka.Driver)
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
    KafkaEx.create_worker(:kafka_ex)
  end

  @impl true
  def init(_) do
    children = [
      {Tololo.Extensions.Kafka.Supervisor, max_restarts: 10, max_seconds: 60}
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
    end
  end

  @impl true
  def ash_domains(), do: []
end
