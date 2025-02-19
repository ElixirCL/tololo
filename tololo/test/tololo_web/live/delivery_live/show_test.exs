defmodule TololoWeb.DeliveryLive.ShowTest do
  use TololoWeb.ConnCase
  import Phoenix.LiveViewTest

  alias TololoCore.Deliveries.Delivery

  setup do
    {:ok, delivery: Delivery.empty!(actor: TololoCore.Deliveries.Actors.admin())}
  end

  def auth_conn(conn),
    do:
      conn
      |> Plug.Conn.put_req_header(
        "authorization",
        "Basic " <> Base.encode64("admin:#{System.get_env("ADMIN_API_KEY")}")
      )

  test "displays delivery details", %{conn: conn, delivery: delivery} do
    conn = conn |> auth_conn
    {:ok, _show_live, html} = live(conn, ~p"/deliveries/#{delivery.id}")

    assert html =~ "Delivery #{delivery.display_id}"
    assert html =~ "Init"
  end

  test "redirects to edit when clicking edit button", %{conn: conn, delivery: delivery} do
    conn = conn |> auth_conn

    {:ok, show_live, _html} = live(conn, ~p"/deliveries/#{delivery.id}")

    assert show_live
           |> element("a", "Edit Delivery")
           |> render_click() =~
             "Update delivery"
  end
end
