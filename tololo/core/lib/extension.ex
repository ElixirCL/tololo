defmodule TololoCore.Extension do
  @moduledoc """
  Defines the extension behaviour.
  """
  @callback routes() :: Macro.t()
  @callback endpoint() :: Macro.t()
  @callback ash_domains() :: [Ash.Domain.t()]
  @callback child_spec(any()) :: Supervisor.child_spec()
  # @callback payment()
  
  @extensions Application.compile_env(:tololo, :extensions)

  defmacro __using__(:routes) do
    quote do
      unquote(
        @extensions
        |> Enum.map(fn extension_module -> extension_module.routes() end)
      )
    end
  end

  defmacro __using__(:endpoint) do
    quote do
      unquote(
        @extensions
        |> Enum.map(fn extension_module -> extension_module.endpoint() end)
      )
    end
  end
end
