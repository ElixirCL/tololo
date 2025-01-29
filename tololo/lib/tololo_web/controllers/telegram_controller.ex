defmodule TololoWeb.TelegramController do
  use TololoWeb, :controller

  alias Tololo.Extensions.TelegramBot.Handler

  def init(opts) do
    Tololo.Extensions.TelegramBot.init()
    opts
  end

  def update(conn, params) do
    IO.inspect(params, label: "params", limit: :infinity, pretty: true)
    update = Telegex.Helper.typedmap(params, Telegex.Type.Update)
    |> IO.inspect(label: "update", limit: :infinity, pretty: true)

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
end
