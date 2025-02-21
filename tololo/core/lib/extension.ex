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

  defmacro __using__([]) do
    quote do
      @behaviour TololoCore.Extension

      @impl true
      def routes, do: []

      @impl true
      def endpoint do
        quote do
        end
      end

      @impl true
      def ash_domains, do: []

      @impl true
      def child_spec(init_arg),
        do: %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [init_arg]}
        }

      def start_link, do: :ignore
    end
  end
end
