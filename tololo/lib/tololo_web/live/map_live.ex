defmodule TololoWeb.MapLive do
  use TololoWeb, :live_view
  use Gettext, backend: TololoCore.Gettext

  import AshPhoenix.LiveView

  def mount(%{"token" => token}, _session, socket) do
    socket = default_assigns(socket)

    case get_delivery_via_token(token) do
      {:ok, delivery_resource} ->
        {:ok,
         socket
         |> keep_delivery_live(token, delivery_resource)
         |> push_update_event()}

      :error ->
        raise TololoWeb.NotFoundError, gettext("Delivery not found")
    end
  end

  def mount(_params, _session, _socket),
    do: raise(TololoWeb.NotFoundError, gettext("Token not found"))

  defp get_delivery_via_token(token) do
    case TololoCore.Deliveries.Delivery.get_via_token(token,
           actor: TololoCore.Deliveries.Actors.public(),
           load: :state_history
         ) do
      {:ok, [resource]} -> {:ok, resource}
      {:error, _} -> :error
    end
  end

  # Assigns are initialized as nil to avoid errors.
  defp default_assigns(socket),
    do:
      socket
      |> assign(
        resource: nil,
        error: nil,
        head_includes: get_head(),
        map_tooltip: gettext("Current location")
      )

  # Imports Leaflet
  defp get_head(assigns \\ %{}),
    do: ~H"""
    <link
      rel="stylesheet"
      href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
      integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY="
      crossorigin=""
    />
    <script
      src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
      integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo="
      crossorigin=""
    >
    </script>
    """

  defp push_update_event(%{assigns: %{resource: resource}} = socket) do
    push_event(socket, "phx:resource_update", %{
      resource: %{
        from_pos: [resource.from_latitude, resource.from_longitude],
        to_pos: [resource.to_latitude, resource.to_longitude],
        current_pos: [resource.current_latitude, resource.current_longitude],
        from_name: resource.from_name,
        to_name: resource.to_name
      }
    })
  end

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

  def handle_info(
        %{topic: topic, payload: %Ash.Notifier.Notification{}},
        socket
      ) do
    {:noreply, socket |> handle_live(topic, [:resource]) |> push_update_event}
  end

  defp date_to_string(date), do: TololoCore.Cldr.Time.to_string(date) |> elem(1)
end
