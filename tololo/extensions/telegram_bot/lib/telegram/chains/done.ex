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

  defp mark_delivery_done(delivery) do
    Logger.info("Marking #{delivery.display_id} delivery as done")

    %{state: new_state} =
      delivery
      |> Delivery.done_with_distance_check!(nil, actor: @actor)

    if new_state == "Delivery_Done" do
      gettext("""
      Delivery successfully marked as done.
      """)
    else
      gettext("""
      Delivery marked with problems. An admin will review it first.
      """)
    end
  end

  # matches when there's no active deliveries
  @impl true
  def handle(
        %{from: %{id: user_id}, text: _text},
        %{user_resource: %{deliveries: []}} = context
      ) do
    message =
      Message.send_message(
        user_id,
        gettext("""
        You don't have any active deliveries to mark as done.
        """)
      )

    {:done, %{context | payload: message}}
  end

  @impl true
  def handle(
        %{from: %{id: user_id}, text: "#{@command} " <> token},
        %{user_resource: %{deliveries: deliveries}} = context
      ) do
    message_string =
      case Enum.find(deliveries, fn delivery -> delivery.display_id == token end) do
        nil ->
          gettext("""
          Delivery wasn't found.
          """)

        delivery ->
          mark_delivery_done(delivery)
      end

    message =
      Message.send_message(
        user_id,
        message_string
      )

    {:done, %{context | payload: message}}
  end

  # matches when there's no token in the command and one delivery
  @impl true
  def handle(
        %{from: %{id: user_id}, text: _text},
        %{user_resource: %{deliveries: [current_delivery]}} = context
      ) do
    message = Message.send_message(user_id, mark_delivery_done(current_delivery))

    {:done, %{context | payload: message}}
  end

  # matches when there's no token in the command and multiple deliveries
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
