# Script for populating the database with an example store. You can run it as:
#
#     mix run priv/repo/example_seeds.exs
#
require Ash.Query
alias Tololo.Repo
alias TololoCore.Products.{Product, Option, Variant}

product_names = [
  "Handroll",
  "Sushiburger",
  "Gohan",
  "Tabla",
  "Bolitas Apanadas",
  "Gyozas al Vapor",
  "Bastones Apanados",
  "Arrollados Primavera",
  "Alfajor de dátiles"
]

Enum.each(product_names, fn product_name ->
  queried_product =
    Product
    |> Ash.Query.filter(name == ^product_name)
    |> Ash.read_one!()

  case queried_product do
    nil ->
      nil

    product ->
      Repo.delete!(product)
  end

end)

old_brand = TololoCore.Brands.Brand |> Ash.read_one!
if old_brand, do: Repo.delete!(old_brand)

old_branch = TololoCore.Brands.Branch |> Ash.read_one!
if old_branch, do: Repo.delete!(old_branch)

brand = TololoCore.Brands.Brand.create!(%{name: "Sushi"}, authorize?: false)

branch =
  TololoCore.Brands.Branch.create!(
    %{
      name: "Sushi Quilpué",
      latitude: -33.04534,
      longitude: -71.4447094,
      brand_id: brand.id,
      address: "Quilpué"
    },
    authorize?: false
  )

set_prices = fn variants, values_combination, price ->
  values_combination =
    if is_list(values_combination), do: values_combination, else: [values_combination]

  Enum.each(variants, fn variant ->
    if Enum.all?(variant.option_values, fn %{value: value} -> value in values_combination end) do
      Variant.update_price!(variant, price, authorize?: false)
    end
  end)
end

handroll =
  Product.create!(
    %{
      name: "Handroll",
      description: "desc",
      state: :enabled,
      sku: "1234",
      discount_rules: [
        %{
          method: :fixed,
          discount: 3000,
          conditions: [
            %{
              weekdays: [1, 2, 3, 4, 5]
            },
            %{
              from_hour: 3,
              to_hour: 6
            }
          ]
        }
      ]
    },
    authorize?: false
  )
  |> Product.update_price!(%{amount: 3_500, currency: :CLP}, authorize?: false)

handroll_ingredientes = Product.get_or_create_option!(handroll, "Ingredientes", authorize?: false)

[
  "Pepino",
  "Palmito",
  "Aceituna",
  "Champiñón",
  "Zucchini furai",
  "Seitán",
  "Tofu"
]
|> Enum.each(fn value ->
  Option.add_value!(handroll_ingredientes, value, authorize?: false)
end)

handroll = Product.generate_variants!(handroll, authorize?: false)

["Champiñón", "Zucchini furai"]
|> Enum.each(fn ingredient ->
  set_prices.(handroll.variants, ingredient, Money.new!(:CLP, 3_600))
end)

["Seitán", "Tofu"]
|> Enum.each(fn ingredient ->
  set_prices.(handroll.variants, ingredient, Money.new!(:CLP, 3_800))
end)

sushiburger =
  Product.create!(
    %{
      name: "Sushiburger",
      description: "desc",
      state: :enabled,
      sku: "1236",
      discount_rules: [
        %{
          method: :x_for_fixed_price,
          discount: 13000,
          method_data: %{
            quantity_x: 2
          }
        }
      ]
    },
    authorize?: false
  )
  |> Product.update_price!(%{amount: 7_200, currency: :CLP}, authorize?: false)

sushiburger_ingredientes =
  Product.get_or_create_option!(sushiburger, "Ingredientes", authorize?: false)

[
  "Champiñón",
  "Seitán",
  "Tofu"
]
|> Enum.each(fn value ->
  Option.add_value!(sushiburger_ingredientes, value, authorize?: false)
end)

sushiburger = Product.generate_variants!(sushiburger, authorize?: false)

set_prices.(sushiburger.variants, "Champiñón", Money.new!(:CLP, 7_000))

gohan =
  Product.create!(
    %{
      name: "Gohan",
      description: "desc",
      state: :enabled,
      sku: "1235",
      discount_rules: [
        %{
          method: :percentage,
          discount: 0.1,
          conditions: [
            %{
              weekdays: [3, 5]
            }
          ]
        }
      ]
    },
    authorize?: false
  )
  |> Product.update_price!(%{amount: 6_400, currency: :CLP}, authorize?: false)

gohan_ingredientes = Product.get_or_create_option!(gohan, "Ingredientes", authorize?: false)

[
  "Champiñón",
  "Zucchini furai",
  "Seitán",
  "Tofu",
  "Mixto"
]
|> Enum.each(fn value ->
  Option.add_value!(gohan_ingredientes, value, authorize?: false)
end)

gohan = Product.generate_variants!(gohan, authorize?: false)

["Champiñón", "Zucchini furai"]
|> Enum.each(fn ingredient ->
  set_prices.(gohan.variants, ingredient, Money.new!(:CLP, 6_200))
end)

tabla =
  Product.create!(
    %{
      name: "Tabla",
      description: "desc",
      state: :enabled,
      sku: "1237",
      discount_rules: [
        %{
          method: :percentage,
          discount: 0.1,
          conditions: [
            %{
              weekdays: [2]
            }
          ]
        }
      ]
    },
    authorize?: false
  )
  |> Product.update_price!(%{amount: 11_000, currency: :CLP}, authorize?: false)

tabla_tipos = Product.get_or_create_option!(tabla, "Tipo", authorize?: false)

[
  "20 cortes",
  "30 cortes (palta - sésamo - panko)",
  "30 cortes (panko)",
  "40 cortes",
  "50 cortes (palta - queso - sésamo - panko)",
  "50 cortes (tempura - panko)",
  "100 cortes"
]
|> Enum.each(fn value ->
  Option.add_value!(tabla_tipos, value, authorize?: false)
end)

tabla = Product.generate_variants!(tabla, authorize?: false)

set_prices.(tabla.variants, "30 cortes (palta - sésamo - panko)", Money.new!(:CLP, 15_500))
set_prices.(tabla.variants, "30 cortes (panko)", Money.new!(:CLP, 16_500))
set_prices.(tabla.variants, "40 cortes", Money.new!(:CLP, 19_500))

set_prices.(
  tabla.variants,
  "50 cortes (palta - queso - sésamo - panko)",
  Money.new!(:CLP, 23_000)
)

set_prices.(tabla.variants, "50 cortes (tempura - panko)", Money.new!(:CLP, 24_000))
set_prices.(tabla.variants, "100 cortes", Money.new!(:CLP, 40_000))

bolitas_apanadas =
  Product.create!(
    %{
      name: "Bolitas Apanadas",
      description: "Champi, queso caju y cebollín",
      state: :enabled,
      sku: "1240"
    },
    authorize?: false
  )
  |> Product.update_price!(%{amount: 3_700, currency: :CLP}, authorize?: false)

bolitas_unidades = Product.get_or_create_option!(bolitas_apanadas, "Unidades", authorize?: false)

[
  "4 unidades",
  "8 unidades"
]
|> Enum.each(fn value ->
  Option.add_value!(bolitas_unidades, value, authorize?: false)
end)

bolitas_apanadas = Product.generate_variants!(bolitas_apanadas, authorize?: false)

set_prices.(bolitas_apanadas.variants, "4 unidades", Money.new!(:CLP, 3_700))
set_prices.(bolitas_apanadas.variants, "8 unidades", Money.new!(:CLP, 7_000))

gyozas =
  Product.create!(
    %{
      name: "Gyozas al Vapor",
      description: "desc",
      state: :enabled,
      sku: "1242"
    },
    authorize?: false
  )
  |> Product.update_price!(%{amount: 2_500, currency: :CLP}, authorize?: false)

gyozas_unidades = Product.get_or_create_option!(gyozas, "Unidades", authorize?: false)

[
  "4 unidades",
  "6 unidades"
]
|> Enum.each(fn value ->
  Option.add_value!(gyozas_unidades, value, authorize?: false)
end)

gyozas = Product.generate_variants!(gyozas, authorize?: false)

set_prices.(gyozas.variants, "4 unidades", Money.new!(:CLP, 2_500))
set_prices.(gyozas.variants, "6 unidades", Money.new!(:CLP, 4_500))

bastones =
  Product.create!(
    %{
      name: "Bastones Apanados",
      description: "desc",
      state: :enabled,
      sku: "1243"
    },
    authorize?: false
  )
  |> Product.update_price!(%{amount: 2_200, currency: :CLP}, authorize?: false)

bastones_tipo = Product.get_or_create_option!(bastones, "Tipo", authorize?: false)

[
  "tofu",
  "seitán"
]
|> Enum.each(fn value ->
  Option.add_value!(bastones_tipo, value, authorize?: false)
end)

bastones_unidades = Product.get_or_create_option!(bastones, "Unidades", authorize?: false)

[
  "4 unidades",
  "8 unidades"
]
|> Enum.each(fn value ->
  Option.add_value!(bastones_unidades, value, authorize?: false)
end)

bastones = Product.generate_variants!(bastones, authorize?: false)

set_prices.(bastones.variants, ["tofu", "4 unidades"], Money.new!(:CLP, 3_200))
set_prices.(bastones.variants, ["tofu", "8 unidades"], Money.new!(:CLP, 6_000))

set_prices.(bastones.variants, ["seitán", "4 unidades"], Money.new!(:CLP, 2_700))
set_prices.(bastones.variants, ["seitán", "8 unidades"], Money.new!(:CLP, 5_000))

arrollados =
  Product.create!(
    %{
      name: "Arrollados Primavera",
      description: "Rellenos de tofu y verduras",
      state: :enabled,
      sku: "1250"
    },
    authorize?: false
  )
  |> Product.update_price!(%{amount: 3_000, currency: :CLP}, authorize?: false)

arrollados_unidades = Product.get_or_create_option!(arrollados, "Unidades", authorize?: false)

[
  "4 unidades",
  "8 unidades"
]
|> Enum.each(fn value ->
  Option.add_value!(arrollados_unidades, value, authorize?: false)
end)

arrollados = Product.generate_variants!(arrollados, authorize?: false)

set_prices.(arrollados.variants, "4 unidades", Money.new!(:CLP, 3_500))
set_prices.(arrollados.variants, "8 unidades", Money.new!(:CLP, 6_500))

alfajor =
  Product.create!(
    %{
      name: "Alfajor de dátiles",
      description: "desc",
      state: :enabled,
      sku: "1251"
    },
    authorize?: false
  )
  |> Product.update_price!(%{amount: 700, currency: :CLP}, authorize?: false)
