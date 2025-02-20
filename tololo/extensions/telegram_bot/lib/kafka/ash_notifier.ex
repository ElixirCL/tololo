defmodule Tololo.Extensions.TelegramBot.Kafka.AshNotifier do
  use Ash.Notifier
  alias Ash.Notifier.Notification

  def notify(%Notification{
        resource: resource,
        action: %{type: :create}
      }) do
    produce(
      resource,
      %{event: "user_request"}
    )
  end

  def notify(%Notification{
        resource: resource,
        action: %{name: :add_deliveries}
      }) do
    produce(
      resource,
      %{event: "user_add_deliveries"}
    )
  end

  def notify(_notif), do: nil

  defp produce(resource, data),
    do: TololoCore.Kafka.produce("tololo-telegram", data |> Map.put(:resource, resource))
end
