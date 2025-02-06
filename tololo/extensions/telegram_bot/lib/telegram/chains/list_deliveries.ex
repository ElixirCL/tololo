defmodule Tololo.Extensions.TelegramBot.ListDeliveries do
  @moduledoc false

  use Gettext, backend: Tololo.Extensions.TelegramBot.Gettext
  use Telegex.Chain, {:command, :list}

  @actor TololoCore.Deliveries.Actors.private()
  @command "/list"

  alias Tololo.Extensions.TelegramBot.Message
  alias Telegex.Type.{KeyboardButton}
  alias TololoCore.Deliveries.Delivery

  @impl true
  def match?(%{text: text, chat: %{type: "private"}}, _context) when text != nil do
    String.starts_with?(text, @command)
  end

  @impl true
  def match?(_message, _context), do: false

  @impl true
  def handle(
        %{chat: _chat, from: %{id: user_id}},
        %{user_resource: _user_resource} = context
      ) do
    available_deliveries = Delivery.get_ready_to_pickup!(actor: @actor)

    available_deliveries_buttons =
      Enum.map(available_deliveries, fn delivery ->
        %KeyboardButton{
          text: "/new " <> delivery.display_id
        }
      end)

    message =
      Message.send_message_with_keyboard(
        user_id,
        gettext("""
        *Hello*

        Please select the delivery you wish to pick up
        """),
        available_deliveries_buttons
      )

    {:done, %{context | payload: message}}
  end
end
