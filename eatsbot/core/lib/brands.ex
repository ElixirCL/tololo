defmodule EatsbotCore.Brands do
  @moduledoc """
  Store the Brand associated.
  """

  use Ash.Domain, 
    otp_app: :eatsbot,
    extensions: [AshGraphql, AshAdmin.Domain],
    validate_config_inclusion?: false

  admin do
    show?(true)
    show_resources([EatsbotCore.Brands.Brand, EatsbotCore.Brands.Branch])
  end

  resources do
    resource EatsbotCore.Brands.Brand
    resource EatsbotCore.Brands.Branch
  end
end
