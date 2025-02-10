defmodule Tololo.Extensions.TelegramBot.ChainHandler do
  @moduledoc false
  alias Tololo.Extensions.TelegramBot
  use Telegex.Chain.Handler

  pipeline([
    TelegramBot.Auth,
    TelegramBot.ListDeliveries,
    TelegramBot.ReceiveLocation,
    TelegramBot.SetToken,
    Tololo.Extensions.TelegramBot.Done
  ])
end
