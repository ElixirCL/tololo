defmodule Tololo.Extensions.TelegramBot.Ash.Users do
  @moduledoc """
  Domain that contains resources related to the delivery system.
  """
  use Ash.Domain, otp_app: :tololo, extensions: [AshGraphql.Domain, AshAdmin.Domain]

  admin do
    show?(true)
    show_resources(Tololo.Extensions.TelegramBot.Ash.User)
  end

  resources do
    resource Tololo.Extensions.TelegramBot.Ash.User
  end
end
