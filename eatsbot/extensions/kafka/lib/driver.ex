defmodule Eatsbot.Extensions.Kafka.Driver do
  @moduledoc """
  Default driver implementation for Kafka.
  """

  @behaviour EatsbotCore.Kafka

  @spec produce(String.t(), String.t(), term()) :: :ok | {:error, term()}
  def produce(topic, message, opts \\ []) do
    KafkaEx.produce(%KafkaEx.Protocol.Produce.Request{
      topic: topic,
      partition: 0,
      required_acks: 1,
      messages: [%KafkaEx.Protocol.Produce.Message{value: message}]
    })
  end
end
