defmodule TololoWeb.MapLive do
  use TololoWeb, :live_view
  use Gettext, backend: TololoWeb.Gettext

  import AshPhoenix.LiveView

  def mount(%{"token" => token}, _session, socket) do
    socket = default_assigns(socket)

    case get_delivery_via_token(token) do
      {:ok, delivery_resource} ->
        {:ok, socket |> keep_delivery_live(token, delivery_resource)}

      :error ->
        raise TololoWeb.NotFoundError, gettext("Delivery not found")
    end
  end

  def mount(_params, _session, _socket),
    do: raise(TololoWeb.NotFoundError, gettext("Token not found"))

  defp get_delivery_via_token(token) do
    case Tololo.Deliveries.Delivery.get_via_token(token, actor: %{access_level: :public}) do
      {:ok, [resource]} -> {:ok, resource}
      {:error, _} -> :error
    end
  end

  # Assigns used should be initialized as nil here to avoid errors.
  defp default_assigns(socket), do: socket |> assign(resource: nil, error: nil)

  # Keeps the delivery resource updated whenever a message to the topic `delivery:updated:\#{delivery_resource.id}` is received through PubSub. Initial resource state is passed through function arg, to be able to pass the id as a topic.
  defp keep_delivery_live(socket, token, delivery_resource),
    do:
      keep_live(
        socket,
        :resource,
        fn _socket, _opts ->
          {:ok, delivery_resource} = get_delivery_via_token(token)
          delivery_resource
        end,
        subscribe: ["delivery:updated:#{delivery_resource.id}"],
        initial: delivery_resource
      )

  def handle_info(%{topic: topic, payload: %Ash.Notifier.Notification{}}, socket),
    do: {:noreply, handle_live(socket, topic, [:resource])}
end
