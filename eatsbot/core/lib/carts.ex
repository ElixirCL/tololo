defmodule EatsbotCore.Carts do
  @moduledoc """
  Domain that contains resources related to the cart system.
  """
  use Ash.Domain,
    otp_app: :eatsbot,
    extensions: [AshGraphql.Domain],
    validate_config_inclusion?: false

  resources do
    resource EatsbotCore.Carts.Cart
    resource EatsbotCore.Carts.CartLine
  end
end
