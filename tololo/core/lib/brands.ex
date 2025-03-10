defmodule TololoCore.Brands do
  @moduledoc """
  Store the Brand associated.
  """

  use Ash.Domain, 
    otp_app: :tololo,
    extensions: [AshGraphql, AshAdmin.Domain],
    validate_config_inclusion?: false

  admin do
    show?(true)
    show_resources([TololoCore.Brands.Brand, TololoCore.Brands.Branch])
  end

  resources do
    resource TololoCore.Brands.Brand
    resource TololoCore.Brands.Branch
  end
end
