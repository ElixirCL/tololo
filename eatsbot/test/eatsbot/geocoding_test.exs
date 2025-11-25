defmodule Eatsbot.GeocodingTest do
  use ExUnit.Case, async: false
  import Eatsbot.RequestStub

  setup do
    start_supervised(Eatsbot.RequestStub)

    table_name = :geocoding_cache

    if :ets.whereis(table_name) == :undefined do
      Eatsbot.GeocodingStore.init()
    else
      :ets.delete_all_objects(table_name)
    end

    :ok
  end

  test "returns cached result for repeated queries" do
    set_response("https://nominatim.openstreetmap.org/search", %{body: [%{"test" => "data"}]})

    assert Eatsbot.Geocoding.query("test") == %{"test" => "data"}

    # should return old cached data
    set_response("https://nominatim.openstreetmap.org/search", %{body: [%{"new" => "data"}]})
    assert Eatsbot.Geocoding.query("test") == %{"test" => "data"}

    assert {:ok, Eatsbot.Geocoding.query("test")} == Eatsbot.GeocodingStore.get_cached("test")
  end

  test "handles API failures gracefully" do
    set_response("https://nominatim.openstreetmap.org/search", %{body: []})

    assert_raise MatchError, fn ->
      Eatsbot.Geocoding.query("failure_test")
    end

    assert Eatsbot.GeocodingStore.get_cached("failure_test") == :error
  end

  test "uses configured endpoint and token" do
    # revert env change after test
    original_endpoint = Application.get_env(:eatsbot, :geocoding_endpoint)
    original_token = Application.get_env(:eatsbot, :geocoding_token)

    on_exit(fn ->
      Application.put_env(:eatsbot, :geocoding_endpoint, original_endpoint)
      Application.put_env(:eatsbot, :geocoding_token, original_token)
    end)

    Application.put_env(:eatsbot, :geocoding_endpoint, "https://custom.geo/api")
    Application.put_env(:eatsbot, :geocoding_token, "secret")

    set_response("https://custom.geo/api", %{body: [%{"custom" => "data"}]})

    assert Eatsbot.Geocoding.query("custom_endpoint") == %{"custom" => "data"}
  end
end
