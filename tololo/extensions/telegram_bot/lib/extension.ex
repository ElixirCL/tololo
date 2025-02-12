defmodule Tololo.Extensions.TelegramBot do
  @moduledoc false
  alias Tololo.Extensions.TelegramBot

  use Supervisor

  @impl true
  def child_spec(init_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [init_arg]},
      type: :supervisor,
      restart: :permanent
    }
  end

  def start_link(_init_arg) do
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    TelegramBot.Handler.on_boot()

    children = [
      {TelegramBot.Notifier, nil}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end

  @behaviour TololoCore.Extension

  @impl true
  def routes() do
    quote do
      pipeline :telegram_bot_api do
        plug :accepts, ["json"]
      end

      scope "/", Tololo.Extensions.TelegramBot do
        pipe_through :telegram_bot_api
        post "/telegram", Controller, :update
      end
    end
  end

  @impl true
  def ash_domains(), do: [Tololo.Extensions.TelegramBot.Ash.Users]
end
