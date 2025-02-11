defmodule Tololo.Extensions.TelegramBot.Done do
  @moduledoc false

  use Gettext, backend: Tololo.Extensions.TelegramBot.Gettext
  use Telegex.Chain, {:command, :done}

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
          try do
            delivery
            |> TololoCore.Deliveries.Delivery.update_state!(:Delivery_Done, actor: @actor)

            Logger.info("Marking #{token} delivery as done")

            gettext("""
            Delivery successfully marked as done.
            """)
          rescue
            _ ->
              gettext("""
              There was a problem marking delivery as done
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
