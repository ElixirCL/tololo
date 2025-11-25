defmodule Eatsbot.Extensions.TelegramBot.Auth do
  @moduledoc false

  use Gettext, backend: Eatsbot.Extensions.TelegramBot.Gettext
  use Telegex.Chain

  @actor EatsbotCore.Deliveries.Actors.private()

  # extract the message value
  @impl true
  def handle(%{callback_query: message, message: nil, edited_message: nil}, context),
    do: handle(message, context)

  @impl true
  def handle(%{message: message, edited_message: nil}, context), do: handle(message, context)
  @impl true
  def handle(%{edited_message: message, message: nil}, context), do: handle(message, context)
  @impl true
  def handle(%{callback_query: message}, context), do: handle(message, context)
  @impl true
  def handle(%{from: %{is_bot: true, id: user_id}}, context),
    do: {:done, send_denied_message(context, user_id)}

  @impl true
  def handle(%{from: %{id: user_id}}, context) do
    string_id = Integer.to_string(user_id)

    case Ash.get(Eatsbot.Extensions.TelegramBot.Ash.User, string_id,
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
      Eatsbot.Extensions.TelegramBot.Ash.User,
      %{id: user_id, status: :pending, deliveries_id: []},
      action: :create
    )

    context
  end

  defp send_unauthorized_message(context, user_id) do
    %{
      context
      | payload:
          Eatsbot.Extensions.TelegramBot.Message.send_message(
            user_id,
            gettext("""
            Thanks for using Eatsbot Bot. An Admin will contact you soon.
            """)
          )
    }
  end

  defp send_denied_message(context, user_id) do
    %{
      context
      | payload:
          Eatsbot.Extensions.TelegramBot.Message.send_message(
            user_id,
            gettext("""
            You don't have access to this bot.
            """)
          )
    }
  end
end
