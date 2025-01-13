defmodule Tololo.Kafka.Driver do
  @moduledoc """
  Default driver implementation for Kafka.
  """

  @behaviour Tololo.Kafka

  def produce(topic, partition, value, opts \\ []) do
    KafkaEx.produce(topic, partition, value, opts)
  end
end
