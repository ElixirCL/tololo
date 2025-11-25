defmodule Eatsbot.Extensions.Prometheus.PromExPlugin do
  use PromEx.Plugin

  @impl true
  def event_metrics(_opts) do
    Event.build(
      :eatsbot_deliveries,
      [
        counter(
          [:ash, :deliveries, :create, :count],
          event_name: [:ash, :deliveries, :create, :stop],
          description: "Total number of delivery creations",
          measurement: :count,
          tags: [:action],
          tag_values: fn metadata ->
            %{
              action: metadata.action
            }
          end
        ),
        counter(
          [:ash, :deliveries, :update, :state, :count],
          event_name: [:ash, :deliveries, :update, :stop],
          description: "Total number of state changes",
          measurement: :count,
          tags: [:action],
          tag_values: fn metadata ->
            %{
              action: metadata.action
            }
          end
        ),
        counter(
          [:ash, :deliveries, :update, :state, :individual, :count],
          event_name: [:ash, :deliveries, :update, :state],
          description: "Total number of state changes for individual state",
          measurement: :count,
          tags: [:action, :state],
          tag_values: fn metadata ->
            %{
              action: metadata.action,
              state: metadata.new_state
            }
          end
        ),
        counter(
          [:ash, :users, :approve, :count],
          event_name: [:ash, :users, :approve],
          description: "Total number of approved users",
          measurement: :count
        ),
        counter(
          [:ash, :users, :delivery, :assigned, :count],
          event_name: [:ash, :users, :delivery, :assigned],
          description: "Total number of assigned deliveries to users",
          measurement: :count
        ),
        counter(
          [:ash, :users, :delivery, :done, :count],
          event_name: [:ash, :users, :delivery, :done],
          description: "Total number of deliveries marked as done by users",
          measurement: :count
        )
      ]
    )
  end
end
