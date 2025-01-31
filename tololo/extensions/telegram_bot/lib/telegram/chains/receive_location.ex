defmodule Tololo.Extensions.TelegramBot.ReceiveLocation do
  @moduledoc false
  alias Tololo.Extensions.TelegramBot
  alias Tololo.Deliveries

  use Telegex.Chain, :edited_message

  @impl true
  def match?(%{chat: %{type: "private"}, location: location}, context), do: true

  @impl true
  def handle(
        %{from: %{id: user_id}, location: %{latitude: lat, longitude: lng}},
        context
      ) do
    context =
      with {:ok, token} <- TelegramBot.Store.get_delivery_token(user_id),
           {:ok, delivery_resource} <-
             Deliveries.Delivery.get_via_display_id(token, actor: Deliveries.Actors.private()),
           {:ok, _} <-
             Deliveries.Delivery.update_location(delivery_resource, lat, lng,
               actor: Deliveries.Actors.private()
             ) do
        IO.inspect("location updated")
        context
      else
        {:error, :not_found} ->
          %{
            context
            | payload:
                TelegramBot.send_message(
                  user_id,
                  "No active delivery found. Please start one by using `/new {token}`."
                )
          }

        _ ->
          %{
            context
            | payload:
                TelegramBot.send_message(
                  user_id,
                  "Error trying to update location. Is the delivery still valid?"
                )
          }
      end

    {:done, context}
  end
end
