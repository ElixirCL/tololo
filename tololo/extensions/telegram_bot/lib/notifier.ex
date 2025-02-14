defmodule Tololo.Extensions.TelegramBot.Notifier do
  use GenServer
  use Gettext, backend: Tololo.Extensions.TelegramBot.Gettext

  alias Tololo.Extensions.TelegramBot
  alias Phoenix.PubSub
  @topic "delivery:updated"

  alias Telegex.Type.{InlineKeyboardMarkup, InlineKeyboardButton}

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    pubsub = Application.fetch_env!(:tololo, :pubsub)
    PubSub.subscribe(pubsub, @topic)
    {:ok, nil}
  end

  @impl true
  def handle_info(
        %{
          topic: @topic,
          payload: %{
            data: %{
              state: "Delivery_With_Problems",
              delivery_person: %{"type" => "telegram", "data" => user_data},
              display_id: display_id
            }
          }
        },
        state
      ) do
    Telegex.send_message(
      user_data["user_id"],
      gettext("There's a problem with the delivery {display_id}. Please contact the business.",
        display_id: display_id
      )
    )

    {:noreply, state}
  end

  @impl true
  def handle_info(
        %{
          topic: @topic,
          payload: %{
            data: %{
              state: "In_Delivery",
              delivery_person: %{"type" => "telegram", "data" => user_data},
              display_id: display_id
            },
            # check that the previous state was Delivery_With_Problems
            changeset: %{data: %{state: "Delivery_With_Problems"}}
          }
        },
        state
      ) do
    Telegex.send_message(
      user_data["user_id"],
      gettext(
        """
        The problem with delivery {display_id} was solved.

        You can continue sharing the live location for it. If it's already being shared, no further action is needed.
        """,
        display_id: display_id
      )
    )

    {:noreply, state}
  end

  @impl true
  def handle_info(
        %{
          topic: @topic,
          payload: %{
            data: %{
              state: "Ready_To_Pickup",
              id: id,
              display_id: display_id,
              to_address: address,
              delivery_order: delivery_order
            }
          }
        },
        state
      ) do

    Tololo.Extensions.TelegramBot.Ash.User.get_available_users!()
    |> Enum.each(fn %{id: user_id} ->
      Telegex.send_message(
        user_id,
        gettext(
          """
          A new delivery (*{display_id}*) is ready to be picked up.

          Details: *{details}*
          Address: *{address}*.
          """,
          display_id: display_id,
          address: address || gettext("No address provided"),
          details: Map.get(delivery_order, "data", gettext("No details provided"))
        )
        |> TelegramBot.Message.escape_text(),
        reply_markup: %InlineKeyboardMarkup{
          inline_keyboard: [
            [%InlineKeyboardButton{text: gettext("Pick up"), callback_data: "pickup:#{id}"}]
          ]
        },
        parse_mode: "MarkdownV2"
      )
    end)

    {:noreply, state}
  end

  @impl true
  def handle_info(_message, state), do: {:noreply, state}
end
