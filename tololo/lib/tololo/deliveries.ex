defmodule Tololo.Deliveries do
  use Ash.Domain, otp_app: :tololo, extensions: [AshGraphql.Domain]

  resources do
    resource Tololo.Deliveries.Delivery
    resource Tololo.Deliveries.DeliveryStateChanges
  end
end
