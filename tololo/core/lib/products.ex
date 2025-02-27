defmodule TololoCore.Products do
  @moduledoc """
  Domain that contains resources related to product management.
  """
  use Ash.Domain,
    otp_app: :tololo,
    extensions: [AshGraphql.Domain, AshAdmin.Domain],
    validate_config_inclusion?: false

  admin do
    show?(true)
    show_resources(TololoCore.Products.Product)
  end

  resources do
    resource TololoCore.Products.Product
    resource TololoCore.Products.ProductOption

    resource TololoCore.Products.Variant
    resource TololoCore.Products.VariantOption

    resource TololoCore.Products.CollectionProduct
    resource TololoCore.Products.Collection

    resource TololoCore.Products.Option
    resource TololoCore.Products.OptionValue

    resource TololoCore.Products.Type
  end
end
