defmodule Eatsbot.Extensions.TelegramBot.ChainHandler do
  @moduledoc false
  alias Eatsbot.Extensions.TelegramBot
  use Telegex.Chain.Handler

  pipeline([
    TelegramBot.Auth,
    TelegramBot.ReceiveLocation,
    TelegramBot.SetToken,
    TelegramBot.SetTokenCallback,
    Eatsbot.Extensions.TelegramBot.Done
  ])
end
