defmodule TololoWeb.MapLiveTest do
  use TololoWeb.ConnCase, async: false
  use Gettext, backend: TololoCore.Gettext

  import Phoenix.LiveViewTest

  defp get_element_string(string), do: ~s(.leaflet-marker-icon[title="#{string}"])

  describe "map" do
    test "sending and receiving resource update events", %{conn: conn} do
      %{id: id, public_auth_key: public_auth_key, from_name: from_name, to_name: to_name} =
        delivery_resource =
        TololoCore.Deliveries.Delivery.empty!(authorize?: false)
        |> TololoCore.Deliveries.Delivery.update_state!(:In_Preparation, authorize?: false)
        |> TololoCore.Deliveries.Delivery.update_state!(:Ready_To_Pickup, authorize?: false)
        |> TololoCore.Deliveries.Delivery.update_state!(:In_Delivery, authorize?: false)

      conn = get(conn, "/map?token=#{public_auth_key}")
      {:ok, view, html} = live(conn)

      {new_lat, new_lng} = {1234.0, 5678.0}
      TololoCore.Deliveries.Delivery.update_location!(delivery_resource, new_lat, new_lng,
        authorize?: false
      )

      updated_event = "delivery:updated:#{id}"
      assert_received(updated_event)

      assert_push_event(view, "phx:resource_update", %{
        resource: %{
          current_pos: [^new_lat, ^new_lng]
        }
      })
    end
  end
end
