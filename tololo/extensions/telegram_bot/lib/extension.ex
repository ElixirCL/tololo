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

  # helper functions

  def send_message(chat_id, text),
    do: %{
      method: "sendMessage",
      chat_id: chat_id,
      text: escape_text(text),
      parse_mode: "MarkdownV2"
    }

  defp escape_text(text),
    do:
      text
      |> String.replace(".", "\\.")
      |> String.replace("-", "\\-")
      |> String.replace("!", "\\!")
      |> String.replace("_", "\\_")
      |> String.replace("*", "\\*")
      |> String.replace("[", "\\[")
      |> String.replace("]", "\\]")
      |> String.replace("(", "\\(")
      |> String.replace(")", "\\)")
end
