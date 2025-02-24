defmodule TololoWeb.DeliveryLive.IndexTest do
  use TololoWeb.ConnCase
  import Phoenix.LiveViewTest

  alias TololoCore.Deliveries.Delivery

  setup do
    {:ok,
     deliveries:
       Enum.map(0..5, fn _ -> Delivery.empty!(actor: TololoCore.Deliveries.Actors.admin()) end)}
  end

  def auth_conn(conn),
    do:
      conn
      |> Plug.Conn.put_req_header(
        "authorization",
        "Basic " <> Base.encode64("admin:#{System.get_env("ADMIN_API_KEY")}")
      )

  test "lists deliveries", %{conn: conn, deliveries: deliveries} do
    conn = conn |> auth_conn
    {:ok, _index_live, html} = live(conn, ~p"/deliveries")

    deliveries
    |> Enum.each(fn %{display_id: display_id} ->
      assert html =~ display_id
    end)
  end

  test "handles delete action", %{conn: conn, deliveries: [delivery | _]} do
    conn = conn |> auth_conn
    {:ok, index_live, _html} = live(conn, ~p"/deliveries")

    assert index_live
           |> element("#deliveries-#{delivery.id} a", "Delete")
           |> render_click()

    assert {:error, _} =
             Ash.get(Delivery, delivery.id, actor: TololoCore.Deliveries.Actors.admin())
  end
end
