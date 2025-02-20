defmodule TololoCore.Kafka.AshNotifier do
  use Ash.Notifier
  alias Ash.Notifier.Notification

  def notify(%Notification{
        data: resource,
        action: %{name: :initialize}
      }) do
    produce(
      resource,
      %{event: "delivery_initialized"}
    )
  end

  def notify(%Notification{
        data: resource,
        changeset: %{data: %{state: old_state}},
        action: %{name: :update_state}
      }) do
    produce(
      resource,
      %{event: "delivery_state_change", old_state: old_state}
    )
  end

  def notify(%Notification{
        data: resource,
        changeset: %{data: %{state: old_state}},
        action: %{name: :done_with_distance_check}
      }) do
    produce(
      resource,
      %{event: "delivery_state_change", old_state: old_state}
    )
  end

  def notify(_notif), do: nil

  defp produce(resource, data),
    do: TololoCore.Kafka.produce("tololo-deliveries", data |> Map.put(:resource, resource))
end
