defmodule Tololo.Extensions.TelegramBot.Controller do
  # TODO: Implement proper docs
  @moduledoc false

  require Logger

  use Phoenix.Controller

  alias Tololo.Extensions.TelegramBot.Handler

  def update(conn, params) do
    params = atomize_keys(params)
    Logger.debug(params)

    update = Telegex.Helper.typedmap(params, Telegex.Type.Update)

    Logger.debug(update)

    try do
      Handler.on_update(update)
    rescue
      e ->
        Handler.on_failure(update, {e, __STACKTRACE__})
    end
    |> case do
      {:done, %{payload: payload}} ->
        json(conn, payload)

      _ ->
        json(conn, %{})
    end
  end

  defp atomize_keys(nil), do: nil

  defp atomize_keys(%{__struct__: _} = struct) do
    struct
  end

  defp atomize_keys(%{} = map) do
    map
    |> Enum.map(fn {k, v} -> {String.to_atom(k), atomize_keys(v)} end)
    |> Enum.into(%{})
  end

  defp atomize_keys([head | rest]) do
    [atomize_keys(head) | atomize_keys(rest)]
  end

  defp atomize_keys(not_a_map) do
    not_a_map
  end
end
