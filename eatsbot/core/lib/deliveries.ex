defmodule EatsbotCore.Deliveries do
  @moduledoc """
  Domain that contains resources related to the delivery system.
  """
  use Ash.Domain,
    otp_app: :eatsbot,
    extensions: [AshGraphql.Domain, AshAdmin.Domain],
    validate_config_inclusion?: false

  admin do
    show?(true)
    show_resources(EatsbotCore.Deliveries.Delivery)
  end

  resources do
    resource EatsbotCore.Deliveries.Delivery
    resource EatsbotCore.Deliveries.DeliveryStateChanges
  end
end
