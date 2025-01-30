defmodule Tololo.Extensions.TelegramBot.ListDeliveries do
  @moduledoc false

  use Telegex.Chain, {:command, :list}

  alias Telegex.Type.{ReplyKeyboardMarkup, KeyboardButton}

  @impl true
  def match?(%{text: text, chat: %{type: "private"}}, _context) when text != nil do
    String.starts_with?(text, @command)
  end

  @impl true
  def match?(_message, _context), do: false

  @impl true
  def handle(%{chat: chat, from: %{id: user_id}} = message, context) do
    markup = %ReplyKeyboardMarkup{
      keyboard: [
        [
          # TODO
          # show deliveries here
          # Tololo.Deliveries.Delivery.get_ready_to_pickup() |> Enum.map()
          %KeyboardButton{
            text: "Hello"
          }
        ]
      ]
    }

    send_hello = %{
      method: "sendMessage",
      chat_id: message.chat.id,
      text:
        """
        *Hello*

        Please select the delivery you wish to pick up
        """,
      reply_markup: markup,
      parse_mode: "MarkdownV2",
      disable_web_page_preview: true
    }

    {:done, %{context | payload: send_hello}}
  end
end

