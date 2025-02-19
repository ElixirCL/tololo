defmodule TololoWeb.DeliveryLive.LocationInputComponentTest do
  use TololoWeb.ConnCase
  import Phoenix.LiveViewTest
  import Tololo.RequestStub

  setup do
    start_supervised(Tololo.RequestStub)

    table_name = :geocoding_cache

    if :ets.whereis(table_name) == :undefined do
      Tololo.GeocodingStore.init()
    else
      :ets.delete_all_objects(table_name)
    end

    :ok
  end

  def auth_conn(conn),
    do:
      conn
      |> Plug.Conn.put_req_header(
        "authorization",
        "Basic " <> Base.encode64("admin:#{System.get_env("ADMIN_API_KEY")}")
      )

  test "renders location input component", %{conn: conn} do
    conn = conn |> auth_conn
    {:ok, view, _html} = live(conn, ~p"/deliveries/new")

    assert render(view) =~ "Address"
    assert view |> element("input[name=\"input\"]") |> has_element?()
  end

  test "handles location input updates", %{conn: conn} do
    conn = conn |> auth_conn
    {:ok, view, _html} = live(conn, ~p"/deliveries/new")

    set_response("https://nominatim.openstreetmap.org/search", %{
      body: [%{"display_name" => "data", "lat" => "1.23", "lon" => "1.23"}]
    })

    html =
      view
      |> element("input[name=\"input\"]")
      |> render_blur(%{value: "Test Location"})

    assert html =~ "data"
    assert html =~ ~s(value="1.23")
    assert html =~ ~s(value="1.23")
  end

  test "clears fields when input is empty", %{conn: conn} do
    conn = conn |> auth_conn
    {:ok, view, _html} = live(conn, ~p"/deliveries/new")

    html =
      view
      |> element("input[name=\"input\"]")
      |> render_blur(%{value: ""})

    assert html =~ "Found address will show up here"
    refute html =~ ~s(value="1.23")
  end

  test "handles multiple geocoding results", %{conn: conn} do
    conn = conn |> auth_conn
    {:ok, view, _html} = live(conn, ~p"/deliveries/new")

    set_response("https://nominatim.openstreetmap.org/search", %{
      body: [
        %{"display_name" => "First Result", "lat" => "1.23", "lon" => "4.56"},
        %{"display_name" => "Second Result", "lat" => "7.89", "lon" => "0.12"}
      ]
    })

    html =
      view
      |> element("input[name=\"input\"]")
      |> render_blur(%{value: "Ambiguous Location"})

    assert html =~ ~s(value="1.23")
    assert html =~ ~s(value="4.56")
  end
end
