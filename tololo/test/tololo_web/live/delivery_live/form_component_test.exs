defmodule TololoWeb.DeliveryLive.FormComponentTest do
  use TololoWeb.ConnCase
  import Phoenix.LiveViewTest

  alias TololoCore.Deliveries.Delivery

  @create_attrs %{
    to_name: "valid",
    to_latitude: 1.23,
    to_longitude: 1.23,
    to_address: "Valparaíso, Chile"
  }
  @invalid_attrs %{
    to_name: "invalid",
    to_latitude: nil,
    to_longitude: nil,
    to_address: nil
  }
  @update_attrs %{state: "In_Preparation"}

  def auth_conn(conn),
    do:
      conn
      |> Plug.Conn.put_req_header(
        "authorization",
        "Basic " <> Base.encode64("admin:#{System.get_env("ADMIN_API_KEY")}")
      )

  describe "Form Component" do
    setup do
      {:ok, delivery: Delivery.empty!(actor: TololoCore.Deliveries.Actors.admin())}
    end

    test "renders form", %{conn: conn} do
      conn = conn |> auth_conn
      {:ok, view, _html} = live(conn, ~p"/deliveries/new")

      assert render(view) =~ "New Delivery"
      assert view |> element("form") |> has_element?()
      assert view |> element("#delivery_to_name") |> render()
    end

    test "validates form inputs", %{conn: conn} do
      conn = conn |> auth_conn
      {:ok, view, _html} = live(conn, ~p"/deliveries/new")

      view
      |> form("#delivery-form", delivery: @invalid_attrs)
      |> render_change()

      assert render(view) =~ "is required"
    end

    test "handles valid create submission", %{conn: conn} do
      conn = conn |> auth_conn
      {:ok, view, _html} = live(conn, ~p"/deliveries/new")

      assert view
             |> form("#delivery-form")
             |> render_submit(delivery: @create_attrs) =~ "created successfully"
    end

    test "handles valid edit submission", %{conn: conn, delivery: delivery} do
      conn = conn |> auth_conn
      {:ok, view, _html} = live(conn, ~p"/deliveries/#{delivery.id}/edit")

      assert view
             |> form("#delivery-form")
             |> render_submit(delivery: @update_attrs) =~ "updated successfully"
    end
  end
end
