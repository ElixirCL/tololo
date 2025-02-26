defmodule Tololo.Accounts do
  @moduledoc """
  Domain that contains resources related to the general account system.
  """
  use Ash.Domain,
    extensions: [AshAdmin.Domain],
    otp_app: :tololo

  admin do
    show?(true)
    show_resources(Tololo.Accounts.User)
  end

  resources do
    resource Tololo.Accounts.Token
    resource Tololo.Accounts.User
  end
end
