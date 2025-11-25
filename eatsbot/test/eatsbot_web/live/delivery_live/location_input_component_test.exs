defmodule EatsbotWeb.DeliveryLive.LocationInputComponentTest do
  use EatsbotWeb.ConnCase
  import Phoenix.LiveViewTest
  import Eatsbot.RequestStub

  setup %{conn: conn} do
    start_supervised(Eatsbot.RequestStub)

    table_name = :geocoding_cache

    if :ets.whereis(table_name) == :undefined do
      Eatsbot.GeocodingStore.init()
    else
      :ets.delete_all_objects(table_name)
    end

    {:ok, conn: conn |> EatsbotWeb.ConnCase.admin_session()}
  end

  # |> assign(:current_user, %{admin?: true})

  test "renders location input component", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/deliveries/new")

    assert render(view) =~ "Address"
    assert view |> element("input[name=\"input\"]") |> has_element?()
  end

  test "handles location input updates", %{conn: conn} do
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
    {:ok, view, _html} = live(conn, ~p"/deliveries/new")

    html =
      view
      |> element("input[name=\"input\"]")
      |> render_blur(%{value: ""})

    assert html =~ "Found address will show up here"
    refute html =~ ~s(value="1.23")
  end

  test "handles multiple geocoding results", %{conn: conn} do
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
