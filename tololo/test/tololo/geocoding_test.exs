defmodule Tololo.GeocodingTest do
  use ExUnit.Case, async: false
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

  test "returns cached result for repeated queries" do
    set_response("https://nominatim.openstreetmap.org/search", %{body: [%{"test" => "data"}]})

    assert Tololo.Geocoding.query("test") == %{"test" => "data"}

    # should return old cached data
    set_response("https://nominatim.openstreetmap.org/search", %{body: [%{"new" => "data"}]})
    assert Tololo.Geocoding.query("test") == %{"test" => "data"}

    assert {:ok, Tololo.Geocoding.query("test")} == Tololo.GeocodingStore.get_cached("test")
  end

  test "handles API failures gracefully" do
    set_response("https://nominatim.openstreetmap.org/search", %{body: []})

    assert_raise MatchError, fn ->
      Tololo.Geocoding.query("failure_test")
    end

    assert Tololo.GeocodingStore.get_cached("failure_test") == :error
  end

  test "uses configured endpoint and token" do
    # revert env change after test
    original_endpoint = Application.get_env(:tololo, :geocoding_endpoint)
    original_token = Application.get_env(:tololo, :geocoding_token)

    on_exit(fn ->
      Application.put_env(:tololo, :geocoding_endpoint, original_endpoint)
      Application.put_env(:tololo, :geocoding_token, original_token)
    end)

    Application.put_env(:tololo, :geocoding_endpoint, "https://custom.geo/api")
    Application.put_env(:tololo, :geocoding_token, "secret")

    set_response("https://custom.geo/api", %{body: [%{"custom" => "data"}]})

    assert Tololo.Geocoding.query("custom_endpoint") == %{"custom" => "data"}
  end
end
