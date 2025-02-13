defmodule Tololo.Extensions.TelegramBot.SetToken do
  @moduledoc false
  alias Tololo.Extensions.TelegramBot
  alias TololoCore.Deliveries
  alias Tololo.Extensions.TelegramBot.Ash.User
  alias Telegex.Type.{KeyboardButton}

  use Gettext, backend: Tololo.Extensions.TelegramBot.Gettext

  use Telegex.Chain, {:command, :new}
  @command "/new"

  @actor Deliveries.Actors.private()

  # match command with and without arguments
  @impl true
  def match?(%{text: @command, chat: %{type: "private"}}, _context), do: true
  @impl true
  def match?(%{text: "#{@command} " <> _token, chat: %{type: "private"}}, _context), do: true
  @impl true
  def match?(_message, _context), do: false

  @impl true
  def handle(%{from: %{id: user_id} = from, text: "#{@command} " <> token}, context) do
    case Deliveries.Delivery.get_via_display_id(token, actor: @actor) do
      {:ok, %{state: state} = delivery_resource}
      when state == "Ready_To_Pickup" or state == "In_Delivery" ->
        delivery_resource =
          if state == "Ready_To_Pickup" do
            delivery_resource
            |> Deliveries.Delivery.update_state!(:In_Delivery, actor: @actor)
          else
            delivery_resource
          end
          |> update_delivery_person(from)

        context.user_resource |> User.add_deliveries!([delivery_resource.id], actor: @actor)

        {:done, send_confirmation(context, delivery_resource, user_id)}

      _ ->
        {:done, send_error(context, user_id)}
    end
  end

  # if it doesn't include a token, show list
  def handle(
        %{chat: _chat, from: %{id: user_id}},
        %{user_resource: _user_resource} = context
      ) do
    available_deliveries = Deliveries.Delivery.get_ready_to_pickup!(actor: @actor)

    available_deliveries_buttons =
      Enum.map(available_deliveries, fn delivery ->
        %KeyboardButton{
          text: "/new " <> delivery.display_id
        }
      end)

    message =
      TelegramBot.Message.send_message_with_keyboard(
        user_id,
        gettext("""
        *Hello*

        Please select the delivery you wish to pick up
        """),
        available_deliveries_buttons
      )

    {:done, %{context | payload: message}}
  end

  def send_confirmation(
        context,
        %{to_name: name, to_phone: phone, to_notes: notes, to_address: to_address},
        user_id
      ) do
    send_message =
      TelegramBot.Message.send_message(
        user_id,
        gettext(
          "delivery_info",
          name: name || gettext("Unknown person"),
          phone: phone || gettext("No phone number provided"),
          address: to_address || gettext("No address provided"),
          details: notes || gettext("No additional notes")
        )
      )

    %{context | payload: send_message}
  end

  def send_error(context, user_id) do
    send_message =
      TelegramBot.Message.send_message(
        user_id,
        gettext("""
        There was a problem. Please check that the token is valid.
        """)
      )

    %{context | payload: send_message}
  end

  defp update_delivery_person(delivery_resource, from),
    do:
      delivery_resource
      |> Deliveries.Delivery.update_delivery_person!(
        %{
          delivery_person: %{
            type: "telegram",
            data: %{
              name:
                (from.first_name || gettext("Delivery Person")) <> " " <> (from.last_name || ""),
              user_id: from.id,
              user_handle: from.username,
              image: nil,
              phone: nil
            }
          }
        },
        actor: @actor
      )
end
