defmodule Eatsbot.Extensions.TelegramBot.ChainContext do
  @moduledoc false

  use Telegex.Chain.Context

  defcontext([
    {:chat_id, integer},
    {:user_id, integer},
    {:chat_title, String.t()},
    {:user_resource, Eatsbot.Extensions.TelegramBot.Ash.User.t()}
  ])
end
