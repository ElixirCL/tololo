defmodule Tololo.Support do
  use Ash.Domain,
    otp_app: :tololo

  resources do
    resource Tololo.Support.Ticket
    resource Tololo.Support.Representative
  end
end
