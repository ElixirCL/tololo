defmodule Tololo.Extensions.TelegramBot.SetToken do
  @moduledoc false
  alias Tololo.Extensions.TelegramBot
  alias TololoCore.Deliveries
  alias Tololo.Extensions.TelegramBot.Ash.User

  use Gettext, backend: Tololo.Extensions.TelegramBot.Gettext

  use Telegex.Chain, {:command, :new}
  @command "/new"
  @no_token_message """
  Please include the provided token with the command:

  `#{@command} {token}`
  """

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

  # if it doesn't include a token, send usage instructions
  def handle(%{from: %{id: user_id}}, context) do
    send_message =
      TelegramBot.Message.send_message(
        user_id,
        gettext(@no_token_message)
      )

    {:done, %{context | payload: send_message}}
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
              name: from.first_name <> " " <> (from.last_name || ""),
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
