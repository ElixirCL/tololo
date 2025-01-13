defmodule Tololo.Kafka do
  @moduledoc """
  A kafka interface to send messages.

  Configuration:

  config :tololo, :kafka_driver,
        driver: Tololo.Kafka.Driver
  """

  @doc """
  Produces a message to Kafka. Should be implemented by drivers.
  """
  @callback produce(topic :: String.t(), partition :: non_neg_integer(), message :: String.t(), opts :: term()) ::
              :ok | {:error, term()}

  defp driver, do: Application.get_env(:tololo, :kafka_driver, driver: Tololo.Kafka.Noop)[:driver]

  def produce(topic, partition, value, opts \\ []) do
    driver().produce(topic, partition, value, opts)
  end
end
