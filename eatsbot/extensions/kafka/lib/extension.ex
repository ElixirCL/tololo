defmodule Eatsbot.Extensions.Kafka do
  @moduledoc false
  use Supervisor
  use EatsbotCore.Extension

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
    Application.put_env(:eatsbot, :kafka_driver, Eatsbot.Extensions.Kafka.Driver)
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
    KafkaEx.create_worker(:kafka_ex)
  end

  @impl true
  def init(_) do
    children = [
      {Eatsbot.Extensions.Kafka.Supervisor, max_restarts: 10, max_seconds: 60}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
