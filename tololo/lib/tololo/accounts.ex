defmodule Tololo.Accounts do
  @moduledoc """
  Accounts domain for authentication.
  """
  use Ash.Domain,
    otp_app: :tololo

  resources do
    resource Tololo.Accounts.Token
    resource Tololo.Accounts.User
  end
end
