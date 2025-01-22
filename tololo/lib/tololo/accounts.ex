defmodule Tololo.Accounts do
  use Ash.Domain,
    otp_app: :tololo

  resources do
    resource Tololo.Accounts.Token
    resource Tololo.Accounts.User
  end
end
