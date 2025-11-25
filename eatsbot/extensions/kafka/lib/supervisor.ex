defmodule Eatsbot.Extensions.Kafka.Supervisor do
  @moduledoc """
  Wrapper needed to manually pass the KafkaEx supervisor to the main app's supervision tree.
  """
  def start_link(opts) do
    KafkaEx.Supervisor.start_link(opts[:max_restarts], opts[:max_seconds])
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :supervisor,
      restart: :permanent,
    }
  end
end
