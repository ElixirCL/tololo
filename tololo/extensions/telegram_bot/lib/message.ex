defmodule Tololo.Extensions.TelegramBot.Message do
  @moduledoc """
  Functions that help build messages in MarkdownV2 for Telegex.
  """
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
      # |> String.replace("*", "\\*")
      |> String.replace("[", "\\[")
      |> String.replace("]", "\\]")
      |> String.replace("(", "\\(")
      |> String.replace(")", "\\)")
end
