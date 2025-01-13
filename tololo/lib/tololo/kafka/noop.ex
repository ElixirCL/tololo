defmodule Tololo.Kafka.Noop do
  @moduledoc """
  Noop driver implementation for Kafka. Used when Kafka isn't configured, will always return :ok.
  """

  @behaviour Tololo.Kafka
  
  def produce(_topic, _partition, _value, _opts \\ []), do: :ok
end
