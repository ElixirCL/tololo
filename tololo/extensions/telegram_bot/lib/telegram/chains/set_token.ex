defmodule Tololo.Extensions.TelegramBot.SetToken do
  @moduledoc false
  alias Tololo.Extensions.TelegramBot
  alias TololoCore.Deliveries
  alias TololoCore.Deliveries.Delivery
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

  def update_delivery(
        %{state: state, id: delivery_id} = delivery_resource,
        %{id: user_id} = from,
        %{user_resource: user_resource} = context
      )
      when state == "Ready_To_Pickup" do
    with {:ok, delivery_resource} <-
           delivery_resource |> update_delivery_person(from),
         {:ok, delivery_resource} <-
           delivery_resource |> Delivery.update_state("In_Delivery", actor: @actor),
         {:ok, _user_resource} <-
           user_resource |> User.add_deliveries([delivery_id], actor: @actor) do
      {:done, send_confirmation(context, delivery_resource, user_id)}
    else
      _ -> {:done, send_error(context, user_id)}
    end
  end

  def update_delivery(_, %{id: user_id}, context), do: {:done, send_error(context, user_id)}

  @impl true
  def handle(%{from: from, text: "#{@command} " <> token}, context) do
    delivery_resource =
      case Deliveries.Delivery.get_via_display_id(token, actor: @actor) do
        {:ok, resource} -> resource
        # will match against the error clause
        other -> other
      end

    update_delivery(delivery_resource, from, context)
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

  def get_delivery_info(%{
        to_name: name,
        to_phone: phone,
        to_notes: notes,
        to_address: to_address
      }),
      do:
        gettext(
          "delivery_info",
          name: name || gettext("Unknown person"),
          phone: phone || gettext("No phone number provided"),
          address: to_address || gettext("No address provided"),
          notes: notes || gettext("No additional notes")
        )

  def send_confirmation(
        context,
        delivery_resource,
        user_id
      ) do
    send_message =
      TelegramBot.Message.send_message(
        user_id,
        get_delivery_info(delivery_resource)
      )

    %{context | payload: send_message}
  end

  def send_error(context, user_id) do
    send_message =
      TelegramBot.Message.send_message(
        user_id,
        gettext("""
        There was a problem. Please check that the delivery is still valid.
        """)
      )

    %{context | payload: send_message}
  end

  def update_delivery_person(delivery_resource, from),
    do:
      delivery_resource
      |> Deliveries.Delivery.update_delivery_person(
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

defmodule Tololo.Extensions.TelegramBot.SetTokenCallback do
  @moduledoc false

  alias TololoCore.Deliveries.Delivery
  alias TololoCore.Deliveries
  alias Tololo.Extensions.TelegramBot

  use Telegex.Chain, {:callback_query, prefix: "pickup:"}
  @actor Deliveries.Actors.private()

  @impl true
  def handle(
        %{id: callback_id, data: "pickup:" <> delivery_id, from: from},
        context
      ) do
    delivery_resource =
      case Ash.get!(Delivery, delivery_id, actor: @actor) do
        {:ok, resource} -> resource
        other -> other
      end

    result = TelegramBot.SetToken.update_delivery(delivery_resource, from, context)

    Telegex.answer_callback_query(callback_id)

    result
  end
end
