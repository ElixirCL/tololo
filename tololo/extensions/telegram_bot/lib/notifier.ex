defmodule Tololo.Extensions.TelegramBot.Notifier do
  use GenServer
  use Gettext, backend: Tololo.Extensions.TelegramBot.Gettext

  alias Phoenix.PubSub
  @topic "delivery:updated"

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
  def handle_info(message, state), do: {:noreply, state}
end
