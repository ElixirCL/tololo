defmodule ProductTest do
  use Tololo.DataCase, async: true

  alias TololoCore.Products.{Product, Option, Collection, Type}

  describe "product lifecycle" do
    test "creates product with discount rules and prices" do
      product =
        Product.create!(
          %{
            name: "Test Product",
            description: "Test Description",
            state: :enabled,
            sku: "TEST_SKU",
            discount_rules: [
              %{discount: 50_000, method: :fixed}
            ]
          },
          authorize?: false
        )

      assert product.name == "Test Product"
      assert [%{method: :fixed}] = product.discount_rules

      product = Product.update_price!(product, %{amount: 20, currency: :USD}, authorize?: false)
      product = Product.update_price!(product, %{amount: 20_000, currency: :CLP}, authorize?: false)

      assert Enum.count(product.prices) == 2
    end
  end

  describe "product variants" do
    setup do
      product =
        Product.create!(
          %{
            name: "Test Product",
            description: "Description",
            state: :enabled,
            sku: "TEST_SKU",
          },
          authorize?: false
        )
        |> Product.update_price!(%{amount: 100, currency: :USD}, authorize?: false)

      {:ok, product: product}
    end

    test "generates variants from options", %{product: product} do
      option1 = Product.get_or_create_option!(product, "Color", authorize?: false)
      option2 = Product.get_or_create_option!(product, "Size", authorize?: false)
      
      Enum.reduce(["Red", "Blue"], option1, fn val, acc ->
        Option.add_value!(acc, val, authorize?: false)
      end)

      Enum.reduce(["S", "M"], option2, fn val, acc ->
        Option.add_value!(acc, val, authorize?: false)
      end)

      product = Product.generate_variants!(product, authorize?: false)

      assert length(product.variants) == 4
    end
  end

  describe "collections" do
    test "adds product to collection" do
      product = Product.create!(%{
            name: "Test Product",
            description: "Description",
            state: :enabled,
            sku: "TEST_SKU",
          }, authorize?: false)
      %{id: collection_id} = Collection.create!(%{name: "Featured"}, authorize?: false)

      updated_product = Product.add_to_collection!(product, collection_id, authorize?: false)
      assert [%{id: ^collection_id}] = updated_product.collections
    end
  end

  describe "product types" do
    test "creates new product type" do
      {:ok, type} = Ash.create(Type, %{name: "Electronics"}, authorize?: false)
      assert type.name == "Electronics"
    end
  end
end

