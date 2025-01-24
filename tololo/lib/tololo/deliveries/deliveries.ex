defmodule Tololo.Deliveries do
  @moduledoc """
  Domain that contains resources related to the delivery system.
  """
  use Ash.Domain, otp_app: :tololo, extensions: [AshGraphql.Domain, AshAdmin.Domain]

  admin do
    show?(true)
    show_resources Tololo.Deliveries.Delivery
  end

  resources do
    resource Tololo.Deliveries.Delivery
    resource Tololo.Deliveries.DeliveryStateChanges
  end
end
