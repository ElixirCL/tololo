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

  defmacro __using__([]) do
    quote do
      @behaviour TololoCore.Extension

      @before_compile TololoCore.Extension
    end
  end

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

  @doc false
  defmacro __before_compile__(env) do
    functions = Module.definitions_in(env.module)

    quote do
      if not Enum.member?(unquote(functions), {:routes, 0}) do
        @impl true
        def routes, do: []
      end

      if not Enum.member?(unquote(functions), {:endpoint, 0}) do
        @impl true
        def endpoint do
          quote do
          end
        end
      end

      if not Enum.member?(unquote(functions), {:ash_domains, 0}) do
        @impl true
        def ash_domains, do: []
      end

      if not Enum.member?(unquote(functions), {:child_spec, 1}) do
        @impl true
        def child_spec(init_arg),
          do: %{
            id: __MODULE__,
            start: {__MODULE__, :start_link, [init_arg]}
          }
      end

      if not Enum.member?(unquote(functions), {:start_link, 1}) do
        def start_link(_), do: :ignore
      end
    end
  end
end
