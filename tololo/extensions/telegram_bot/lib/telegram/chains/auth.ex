defmodule Tololo.Extensions.TelegramBot.Auth do
  @moduledoc false

  use Gettext, backend: Tololo.Extensions.TelegramBot.Gettext
  use Telegex.Chain

  @actor TololoCore.Deliveries.Actors.private()

  # extract the message value from both messages and edited messages
  @impl true
  def handle(%{message: message, edited_message: nil}, context), do: handle(message, context)
  @impl true
  def handle(%{edited_message: message, message: nil}, context), do: handle(message, context)

  @impl true
  def handle(%{from: %{id: user_id}}, context) do
    string_id = Integer.to_string(user_id)

    case Ash.get(Tololo.Extensions.TelegramBot.Ash.User, string_id,
           actor: @actor,
           load: :deliveries
         ) do
      {:ok, %{status: :allowed} = user} ->
        {:ok, %{context | user_resource: user}}

      {:ok, %{status: :denied}} ->
        {:done, send_denied_message(context, user_id)}

      {:ok, %{status: :pending}} ->
        {:done, send_unauthorized_message(context, user_id)}

      {:error, _} ->
        {:done, context |> init_user(string_id) |> send_unauthorized_message(user_id)}
    end
  end

  defp init_user(context, user_id) do
    Ash.create!(
      Tololo.Extensions.TelegramBot.Ash.User,
      %{id: user_id, status: :pending, deliveries_id: []},
      action: :create
    )

    context
  end

  defp send_unauthorized_message(context, user_id) do
    %{
      context
      | payload:
          Tololo.Extensions.TelegramBot.Message.send_message(
            user_id,
            gettext("""
            Thanks for using Tololo Bot. An Admin will contact you soon.
            """)
          )
    }
  end

  defp send_denied_message(context, user_id) do
    %{
      context
      | payload:
          Tololo.Extensions.TelegramBot.Message.send_message(
            user_id,
            gettext("""
            You don't have access to this bot.
            """)
          )
    }
  end
end
