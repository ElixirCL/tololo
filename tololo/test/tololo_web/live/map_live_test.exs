defmodule TololoWeb.MapLiveTest do
  use TololoWeb.ConnCase, async: false
  use Gettext, backend: Tololo.Gettext

  import Phoenix.LiveViewTest

  defp get_element_string(string), do: ~s(.leaflet-marker-icon[title="#{string}"])

  describe "map" do
    test "raises error for missing token", %{conn: conn} do
      assert_raise TololoWeb.NotFoundError, gettext("Token not found"), fn ->
        live_isolated(conn, TololoWeb.MapLive)
      end
    end

    test "raises error for invalid token", %{conn: conn} do
      assert_raise TololoWeb.NotFoundError, gettext("Delivery not found"), fn ->
        get(conn, "/map?token=invalid_token")
      end
    end

    test "sending and receiving resource update events", %{conn: conn} do
      %{id: id, public_auth_key: public_auth_key, from_name: _from_name, to_name: _to_name} =
        delivery_resource =
        TololoCore.Deliveries.Delivery.empty!(authorize?: false)
        |> TololoCore.Deliveries.Delivery.update_state!(:In_Preparation, authorize?: false)
        |> TololoCore.Deliveries.Delivery.update_state!(:Ready_To_Pickup, authorize?: false)
        |> TololoCore.Deliveries.Delivery.update_state!(:In_Delivery, authorize?: false)

      conn = get(conn, "/map?token=#{public_auth_key}")
      {:ok, view, _html} = live(conn)

      {new_lat, new_lng} = {1234.0, 5678.0}

      topic = "delivery:updated:#{id}"
      Phoenix.PubSub.subscribe(Tololo.PubSub, topic)

      TololoCore.Deliveries.Delivery.update_location!(delivery_resource, new_lat, new_lng,
        authorize?: false
      )

      assert_received(%{topic: ^topic})

      assert_push_event(view, "phx:resource_update", %{
        resource: %{
          current_pos: [^new_lat, ^new_lng]
        }
      })
    end
  end
end
