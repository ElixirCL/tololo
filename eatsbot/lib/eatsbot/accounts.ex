defmodule Eatsbot.Accounts do
  @moduledoc """
  Domain that contains resources related to the general account system.
  """
  use Ash.Domain,
    extensions: [AshAdmin.Domain],
    otp_app: :eatsbot

  admin do
    show?(true)
    show_resources(Eatsbot.Accounts.User)
  end

  resources do
    resource Eatsbot.Accounts.Token
    resource Eatsbot.Accounts.User
  end
end
