defmodule TololoCore.Carts do
  @moduledoc """
  Domain that contains resources related to the cart system.
  """
  use Ash.Domain,
    otp_app: :tololo,
    extensions: [AshGraphql.Domain],
    validate_config_inclusion?: false

  resources do
    resource TololoCore.Carts.Cart
    resource TololoCore.Carts.CartLine
  end
end
