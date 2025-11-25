defmodule EatsbotCore.Products do
  @moduledoc """
  Domain that contains resources related to product management.
  """
  use Ash.Domain,
    otp_app: :eatsbot,
    extensions: [AshGraphql.Domain, AshAdmin.Domain],
    validate_config_inclusion?: false

  admin do
    show?(true)
    show_resources(EatsbotCore.Products.Product)
  end

  resources do
    resource EatsbotCore.Products.Product
    resource EatsbotCore.Products.ProductOption

    resource EatsbotCore.Products.Variant
    resource EatsbotCore.Products.VariantOption

    resource EatsbotCore.Products.CollectionProduct
    resource EatsbotCore.Products.Collection

    resource EatsbotCore.Products.Option
    resource EatsbotCore.Products.OptionValue

    resource EatsbotCore.Products.Price

    resource EatsbotCore.Products.Type
  end
end
