defmodule CartTest do
  use Eatsbot.DataCase, async: true

  alias EatsbotCore.Carts.Cart
  alias EatsbotCore.Products.{Product, Option}

  setup do
    product =
      Product.create!(
        %{
          name: "Test Product",
          description: "Description",
          state: :enabled,
          sku: "TEST_SKU",
          discount_rules: []
        },
        authorize?: false
      )
      |> Product.update_price!(%{amount: 1000, currency: :CLP}, authorize?: false)

    option = Product.get_or_create_option!(product, "Color", authorize?: false)
    Option.add_value!(option, "Red", authorize?: false)
    
    product =
      product
      |> Ash.load!(options: [:option_values])
      |> Product.generate_variants!(authorize?: false)
      |> Ash.load!(variants: [:prices])

    variant = hd(product.variants)
    
    {:ok, product: product, variant: variant}
  end

  describe "cart operations" do
    test "adds variant to cart", %{variant: variant} do
      cart = Cart.create!()
      %{cart_lines: [line]} = Cart.add_variant!(cart, variant.id, 2, "Handle with care")
      
      assert line.quantity == 2
      assert line.notes == "Handle with care"
    end

    test "performs checkout with delivery", %{variant: variant} do
      cart = Cart.create!()
      |> Cart.add_variant!(variant.id, 1, "")

      delivery_public_token =
        Cart.checkout_delivery!(
          cart.id,
          %{
            to_name: "Nombre",
            to_address: "123",
            to_phone: "12345678",
            to_latitude: 40.7128,
            to_longitude: -74.0060,
            delivery_person: %{},
            delivery_order: %{}
          }
        )
      assert EatsbotCore.Deliveries.Delivery.get_via_token(delivery_public_token)
    end
  end
end

