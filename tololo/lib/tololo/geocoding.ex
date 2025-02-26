defmodule Tololo.Geocoding do
  @moduledoc """
  Module for geocoding. It uses the Nominatim API as a fallback. It can be changed through config.
  """
  def query(query_string) do
    case Tololo.GeocodingStore.get_cached(query_string) do
      {:ok, result} -> result
      _ -> fetch_from_provider(query_string)
    end
  end

  defp fetch_from_provider(query_string) do
    endpoint =
      Application.get_env(
        :tololo,
        :geocoding_endpoint,
        "https://nominatim.openstreetmap.org/search"
      )

    token = Application.get_env(:tololo, :geocoding_token, nil)

    # add token if it exists, for compatible API services such as LocationIQ
    params = [q: query_string, format: "json"] ++ if token, do: [token: token], else: []

    # return only first result
    [result | _tail] =
      Application.get_env(:tololo, :req_impl, Req).get!(endpoint, params: params).body

    Tololo.GeocodingStore.save_in_cache(query_string, result)
    result
  end
end

defmodule Tololo.GeocodingStore do
  @moduledoc """
  ETS cache for the Tololo.Geocoding module. Should be migrated to Postgres in the future.
  """
  @table_name :geocoding_cache

  def init do
    :ets.new(@table_name, [:set, :public, :named_table])
  end

  def save_in_cache(query, result) do
    :ets.insert(@table_name, {query, result})
  end

  def get_cached(query) do
    case :ets.lookup(@table_name, query) do
      [{_query, result}] -> {:ok, result}
      [] -> :error
    end
  end
end
