defmodule Tololo.Extensions.TelegramBot.Message do
  @moduledoc """
  Functions that help build messages in MarkdownV2 for Telegex.
  """

  alias Telegex.Type.{ReplyKeyboardMarkup}

  def send_message(chat_id, text),
    do: %{
      method: "sendMessage",
      chat_id: chat_id,
      text: escape_text(text),
      parse_mode: "MarkdownV2"
    }

  def send_message_with_keyboard(chat_id, text, buttons),
    do:
      send_message(chat_id, text)
      |> Map.merge(%{
        reply_markup: %ReplyKeyboardMarkup{keyboard: [buttons], one_time_keyboard: true},
        disable_web_page_preview: true
      })

  def escape_text(text),
    do:
      text
      |> String.replace(".", "\\.")
      |> String.replace("-", "\\-")
      |> String.replace("!", "\\!")
      |> String.replace("_", "\\_")
      # |> String.replace("*", "\\*")
      |> String.replace("[", "\\[")
      |> String.replace("]", "\\]")
      |> String.replace("(", "\\(")
      |> String.replace(")", "\\)")
end
