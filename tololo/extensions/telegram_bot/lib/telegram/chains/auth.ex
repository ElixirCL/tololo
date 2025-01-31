defmodule Tololo.Extensions.TelegramBot.Auth do
  @moduledoc false

  use Telegex.Chain

  alias Telegex.Type.{ReplyKeyboardMarkup, KeyboardButton}

  # TODO implement auth logic
  @allowed_users [7_746_430_870]

  @impl true
  def handle(%{message: %{from: %{id: user_id}}}, context) do
    case Enum.member?(@allowed_users, user_id) do
      true -> {:ok, context}
      false -> {:done, send_unauthorized_message(context, user_id)}
    end
  end

  defp send_unauthorized_message(context, user_id) do
    send_message = %{
      method: "sendMessage",
      chat_id: user_id,
      text: """
      Thanks for using Tololo Bot. An Admin will contact you soon.
      """,
      parse_mode: "MarkdownV2"
    }

    %{context | payload: send_message}
  end
end
