defmodule Tololo.Extensions.TelegramBot do
  @moduledoc false

  def send_message(chat_id, text),
    do:
      %{
        method: "sendMessage",
        chat_id: chat_id,
        text: escape_text(text),
        parse_mode: "MarkdownV2"
      }

  defp escape_text(text), do: String.replace(text, ".", "\\.") |> String.replace("-", "\\-") |> String.replace("!", "\\!")
end
