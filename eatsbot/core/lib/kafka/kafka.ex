defmodule EatsbotCore.Kafka do
  @moduledoc """
  A kafka interface to send messages.
  """

  # env put by Kafka extension
  defp driver, do: Application.get_env(:eatsbot, :kafka_driver, EatsbotCore.Kafka.Noop)

  @doc """
  Produces a message to Kafka. Should be implemented by drivers.
  """

  @callback produce(String.t(), String.t() | map(), term()) :: :ok | {:error, term()}

  @spec produce(String.t(), String.t() | map(), term()) :: :ok | {:error, term()}
  def produce(topic, message, opts \\ [])

  def produce(topic, message, opts) when is_map(message),
    do: produce(topic, Jason.encode!(message), opts)

  def produce(topic, message, opts), do: driver().produce(topic, message, opts)
end
