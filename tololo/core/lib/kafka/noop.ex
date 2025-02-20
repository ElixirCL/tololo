defmodule TololoCore.Kafka.Noop do
  @moduledoc """
  Noop driver implementation for Kafka. Used when Kafka isn't configured, will always return :ok.
  """

  @behaviour TololoCore.Kafka

  @spec produce(String.t(), String.t(), term()) :: :ok | {:error, term()}
  def produce(_topic, _message, _opts \\ []), do: :ok
end
