defmodule Tololo.Extension do
  @moduledoc """
  Defines the extension behaviour.
  """
  @callback routes() :: Macro.t()
  @callback ash_domains() :: [Ash.Domain.t()]
  @callback init() :: nil
  # @callback payment()
end
