defmodule Tololo.Extensions.TelegramBot.ReceiveLocation do
  @moduledoc false
  alias Tololo.Extensions.TelegramBot
  alias TololoCore.Deliveries

  use Gettext, backend: Tololo.Extensions.TelegramBot.Gettext
  use Telegex.Chain, :edited_message

  @actor TololoCore.Deliveries.Actors.private()

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
                 gettext("No active deliveries found. Please start one by using `/new {token}`.")
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
