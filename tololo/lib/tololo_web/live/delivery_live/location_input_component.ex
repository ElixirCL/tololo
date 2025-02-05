defmodule TololoWeb.DeliveryLive.LocationInputComponent do
  use TololoWeb, :live_component

  def mount(socket) do
    {:ok, assign(socket, location_input: "")}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.label for={@lat_field.id}>{@label}</.label>
      <.input
        name="input"
        value={@location_input}
        phx-target={@myself}
        phx-blur="get_location"
        phx-throttle="1000"
      />
      <.input readonly placeholder="Found address will show up here" field={@address_field} />
      <input hidden type="text" name={@lat_field.name} id={@lat_field.id} value={@lat_field.value} />
      <input hidden type="text" name={@lng_field.name} id={@lng_field.id} value={@lng_field.value} />
      <.error :for={msg <- @lat_field.errors ++ @lng_field.errors}>{msg}</.error>
    </div>
    """
  end

  def handle_event(
        "get_location",
        %{"value" => value},
        socket
      ) do
    socket =
      if value != "",
        do:
          socket
          |> put_location_assigns(Tololo.Geocoding.query(value))
          |> assign(location_input: value),
        else: socket

    {:noreply, socket}
  end

  defp put_location_assigns(socket, %{"display_name" => address, "lat" => lat, "lon" => lng}) do
    socket
    |> update_field_value(:address_field, address)
    |> update_field_value(:lat_field, lat)
    |> update_field_value(:lng_field, lng)
  end

  defp update_field_value(socket, field, new_value),
    do:
      update(socket, field, fn field ->
        %Phoenix.HTML.FormField{field | value: new_value}
      end)
end

# %{
#   "addresstype" => "village",
#   "boundingbox" => ["9.8313543", "9.9078768",
#    "-83.8462579", "-83.7664152"],
#   "class" => "boundary",
#   "display_name" => "Santiago, Cantón de Paraíso, Cartago, 30202, Costa Rica",
#   "importance" => 0.7175122107535223,
#   "lat" => "9.8694792",
#   "licence" => "Data © OpenStreetMap contributors, ODbL 1.0. http://osm.org/copyright",
#   "lon" => "-83.7980749",
#   "name" => "Santiago",
#   "osm_id" => 6282288,
#   "osm_type" => "relation",
#   "place_id" => 285685856,
#   "place_rank" => 16,
#   "type" => "administrative"
# }
