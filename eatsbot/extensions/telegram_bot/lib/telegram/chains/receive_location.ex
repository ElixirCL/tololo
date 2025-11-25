defmodule Eatsbot.Extensions.TelegramBot.ReceiveLocation do
  @moduledoc false
  alias Eatsbot.Extensions.TelegramBot
  alias EatsbotCore.Deliveries

  use Gettext, backend: Eatsbot.Extensions.TelegramBot.Gettext
  use Telegex.Chain, :edited_message

  @actor EatsbotCore.Deliveries.Actors.private()

  @impl true
  def match?(%{chat: %{type: "private"}, location: _location}, _context), do: true
  @impl true
  def match?(_, _), do: false

  @impl true
  def handle(
        %{from: %{id: user_id}, location: %{latitude: lat, longitude: lng}},
        %{user_resource: %{deliveries: deliveries}} = context
      ) do
    cond do
      deliveries == [] ->
        {:done,
         %{
           context
           | payload:
               TelegramBot.Message.send_message(
                 user_id,
                 gettext("No active deliveries found. Please start one by using `/new {token}` or stop sharing location.")
               )
         }}

      Enum.all?(deliveries, fn delivery ->
        Kernel.match?(
          {:ok, _},
          Deliveries.Delivery.update_location(delivery, lat, lng, actor: @actor)
        )
      end) ->
        {:ok, context}

      true ->
        {:done,
         %{
           context
           | payload:
               TelegramBot.Message.send_message(
                 user_id,
                 gettext("Error trying to update location.")
               )
         }}
    end
  end
end
