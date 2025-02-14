defmodule TololoCore.Extension do
  @moduledoc """
  Defines the extension behaviour.
  """
  @callback routes() :: Macro.t()
  @callback ash_domains() :: [Ash.Domain.t()]
  @callback child_spec(any()) :: Supervisor.child_spec()
  # @callback payment()
end
