defmodule Tololo.Extensions.TelegramBot.ChainHandler do
  @moduledoc false

  use Telegex.Chain.Handler

  pipeline([
    Tololo.Extensions.TelegramBot.ListDeliveries
  ])
end
