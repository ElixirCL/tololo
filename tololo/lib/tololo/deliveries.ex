defmodule Tololo.Deliveries do
  @moduledoc """
  Domain that contains resources related to the delivery system.
  """
  use Ash.Domain, otp_app: :tololo, extensions: [AshGraphql.Domain]

  resources do
    resource Tololo.Deliveries.Delivery
    resource Tololo.Deliveries.DeliveryStateChanges
  end
end
