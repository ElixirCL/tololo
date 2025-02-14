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
  @min_done_distance Application.compile_env(:tololo, :min_done_distance_meters)

  @impl true
  def match?(%{text: @command, chat: %{type: "private"}}, _context), do: true
  @impl true
  def match?(%{text: "#{@command} " <> _token, chat: %{type: "private"}}, _context), do: true
  @impl true
  def match?(_, _), do: false

  # matches when there's no active deliveries
  @impl true
  def handle(
        %{from: %{id: user_id}, text: _text},
        %{user_resource: %{deliveries: []}} = context
      ),
      do: response_from_available([], context, user_id)

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
        %{user_resource: %{deliveries: [delivery]}} = context
      ) do
    if get_current_to_distance(delivery) < @min_done_distance do
      [delivery]
    else
      []
    end
    |> response_from_available(context, user_id)
  end

  # matches when there's no token in the command and multiple deliveries
  @impl true
  def handle(
        %{from: %{id: user_id}, text: _text},
        %{user_resource: %{deliveries: current_deliveries}} = context
      ) do
    available_to_mark =
      current_deliveries
      |> Enum.filter(fn delivery -> get_current_to_distance(delivery) < @min_done_distance end)
      |> Enum.sort(&(get_current_to_distance(&1) < get_current_to_distance(&2)))

    response_from_available(available_to_mark, context, user_id)
  end

  defp response_from_available([], context, user_id) do
    message =
      Message.send_message(
        user_id,
        gettext("""
        You don't have any active deliveries to mark as done. Check that you're within the minimum delivery range.
        """)
      )

    {:done, %{context | payload: message}}
  end

  defp response_from_available([current_delivery] = available_to_mark, context, user_id) do
    message = Message.send_message(user_id, mark_delivery_done(current_delivery))

    {:done, %{context | payload: message}}
  end

  defp response_from_available(available_to_mark, context, user_id) do
    available_deliveries_buttons =
      Enum.map(available_to_mark, fn delivery ->
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
        available_deliveries_buttons
      )

    {:done, %{context | payload: message}}
  end

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

  defp get_current_to_distance(%{
         current_latitude: current_lat,
         current_longitude: current_lng,
         to_latitude: to_lat,
         to_longitude: to_lng
       }),
       do: TololoCore.Location.distance({current_lat, current_lng}, {to_lat, to_lng})
end
