defmodule Tololo.Extensions.TelegramBot do
  @moduledoc false

  @behaviour Tololo.Extension

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
  def init(), do: Tololo.Extensions.TelegramBot.Handler.on_boot()

  @impl true
  def ash_domains(), do: [Tololo.Extensions.TelegramBot.Ash.Users]
end
