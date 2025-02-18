defmodule Tololo.Kafka.Driver do
  @moduledoc """
  Default driver implementation for Kafka.
  """

  @behaviour Tololo.Kafka

  @spec produce(String.t(), non_neg_integer(), String.t(), term()) :: :ok | {:error, term()}
  def produce(topic, partition, value, opts \\ []) do
    KafkaEx.produce(topic, partition, value, opts)
  end
end
