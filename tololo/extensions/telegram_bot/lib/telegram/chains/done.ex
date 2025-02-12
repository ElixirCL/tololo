defmodule Tololo.Extensions.TelegramBot.Done do
  @moduledoc false

  use Gettext, backend: Tololo.Extensions.TelegramBot.Gettext
  use Telegex.Chain, {:command, :done}

  require Logger

  @command "/done"

  alias Tololo.Extensions.TelegramBot.Message
  alias Telegex.Type.{KeyboardButton}
  alias TololoCore.Deliveries.Delivery

  @actor TololoCore.Deliveries.Actors.private()

  @impl true
  def match?(%{text: @command, chat: %{type: "private"}}, _context), do: true
  @impl true
  def match?(%{text: "#{@command} " <> _token, chat: %{type: "private"}}, _context), do: true
  @impl true
  def match?(_, _), do: false

  @impl true
  def match?(_message, _context), do: false

  @impl true
  def handle(
        %{from: %{id: user_id}, text: "#{@command} " <> token},
        %{user_resource: %{deliveries: deliveries}} = context
      ) do
    message_string =
      case deliveries
           |> Enum.find(:not_found, fn delivery -> delivery.display_id == token end) do
        :not_found ->
          gettext("""
          Delivery wasn't found.
          """)

        delivery ->
          Logger.info("Marking #{token} delivery as done")

          %{state: new_state} =
            delivery
            |> TololoCore.Deliveries.Delivery.done_with_distance_check!(nil, actor: @actor)

          if new_state == "Delivery_Done" do
            gettext("""
            Delivery successfully marked as done.
            """)
          else
            gettext("""
            Error marking as done. You're not within the minimum range to mark delivery as done.
            """)
          end
      end

    message =
      Message.send_message(
        user_id,
        message_string
      )

    {:done, %{context | payload: message}}
  end

  # matches when there's no token in the command
  @impl true
  def handle(
        %{from: %{id: user_id}, text: _text},
        %{user_resource: %{deliveries: current_deliveries}} = context
      ) do
    current_deliveries_buttons =
      Enum.map(current_deliveries, fn delivery ->
        %KeyboardButton{
          text: "#{@command} " <> delivery.display_id
        }
      end)

    message =
      Message.send_message_with_keyboard(
        user_id,
        gettext("""
        *Hello*

        Please select the delivery you wish to mark as done
        """),
        current_deliveries_buttons
      )

    {:done, %{context | payload: message}}
  end
end
