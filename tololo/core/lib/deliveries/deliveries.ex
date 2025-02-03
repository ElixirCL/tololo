defmodule TololoCore.Deliveries do
  @moduledoc """
  Domain that contains resources related to the delivery system.
  """
  use Ash.Domain,
    otp_app: :tololo,
    extensions: [AshGraphql.Domain, AshAdmin.Domain],
    validate_config_inclusion?: false

  admin do
    show?(true)
    show_resources(TololoCore.Deliveries.Delivery)
  end

  resources do
    resource TololoCore.Deliveries.Delivery
    resource TololoCore.Deliveries.DeliveryStateChanges
  end
end
