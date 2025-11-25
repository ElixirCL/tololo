defmodule EatsbotWeb.DeliveryLive.IndexTest do
  use EatsbotWeb.ConnCase
  import Phoenix.LiveViewTest

  alias EatsbotCore.Deliveries.Delivery

  setup %{conn: conn} do
    {:ok,
     deliveries:
       Enum.map(0..5, fn _ -> Delivery.empty!(actor: EatsbotCore.Deliveries.Actors.admin()) end),
     conn: conn |> EatsbotWeb.ConnCase.admin_session()}
  end

  test "lists deliveries", %{conn: conn, deliveries: deliveries} do
    {:ok, _index_live, html} = live(conn, ~p"/deliveries")

    deliveries
    |> Enum.each(fn %{display_id: display_id} ->
      assert html =~ display_id
    end)
  end

  test "handles delete action", %{conn: conn, deliveries: [delivery | _]} do
    {:ok, index_live, _html} = live(conn, ~p"/deliveries")

    assert index_live
           |> element("#deliveries-#{delivery.id} a", "Delete")
           |> render_click()

    assert {:error, _} =
             Ash.get(Delivery, delivery.id, actor: EatsbotCore.Deliveries.Actors.admin())
  end
end
