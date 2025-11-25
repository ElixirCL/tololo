defmodule Eatsbot.Extensions.TelegramBot.Ash.Users do
  @moduledoc """
  Domain that contains resources related to the delivery system.
  """
  use Ash.Domain,
    otp_app: :eatsbot,
    extensions: [AshGraphql.Domain, AshAdmin.Domain],
    validate_config_inclusion?: false

  admin do
    show?(true)
    show_resources(Eatsbot.Extensions.TelegramBot.Ash.User)
  end

  resources do
    resource Eatsbot.Extensions.TelegramBot.Ash.User
  end
end
