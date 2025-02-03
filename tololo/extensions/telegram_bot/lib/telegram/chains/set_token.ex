defmodule Tololo.Extensions.TelegramBot.SetToken do
  @moduledoc false
  alias Tololo.Extensions.TelegramBot
  alias TololoCore.Deliveries
  alias Tololo.Extensions.TelegramBot.Ash.User

  use Telegex.Chain, {:command, :new}
  @command "/new"

  @actor Deliveries.Actors.private()

  # match command with and without arguments
  @impl true
  def match?(%{text: @command, chat: %{type: "private"}}, context), do: true
  @impl true
  def match?(%{text: "#{@command} " <> token, chat: %{type: "private"}}, context), do: true
  @impl true
  def match?(_, _), do: false

  @impl true
  def handle(%{from: %{id: user_id}, text: "#{@command} " <> token}, context) do
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

        context.user_resource |> User.add_deliveries!([delivery_resource.id], actor: @actor)

        {:done, send_confirmation(context, delivery_resource, user_id)}

      _ ->
        {:done, send_error(context, user_id)}
    end
  end

  # if it doesn't include a token, send usage instructions
  def handle(%{from: %{id: user_id}}, context) do
    send_message =
      TelegramBot.Message.send_message(user_id, """
      Please include the provided token with the command:

      `#{@command} {token}`
      """)

    {:done, %{context | payload: send_message}}
  end

  def send_confirmation(
        context,
        %{to_name: name, to_phone: phone, to_notes: notes, to_address: to_address},
        user_id
      ) do
    send_message =
      TelegramBot.Message.send_message(user_id, """
      *This is the delivery information:*

      - Name: #{name || "Unknown person"}
      - Phone: #{phone || "No phone number provided"}
      - Address: #{notes || "No address provided"}
      - Details: #{notes || "No additional notes"}

      *Great! Please send the live location for at least one hour.*
      """)

    %{context | payload: send_message}
  end

  def send_error(context, user_id) do
    send_message =
      TelegramBot.Message.send_message(user_id, """
      There was a problem. Please check that the token is valid.
      """)

    %{context | payload: send_message}
  end
end
