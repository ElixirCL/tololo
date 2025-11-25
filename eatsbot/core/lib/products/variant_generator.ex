defmodule EatsbotCore.Products.Product.VariantGenerator do
  @moduledoc """
  Generates variants for a product, using its options.
  """
  use Ash.Resource.Change

  @impl true
  @spec change(Ash.Changeset.t(), term(), term()) :: Ash.Changeset.t()
  def change(
        %{
          data: %{
            options: options,
            name: name,
            description: description,
            sku: sku,
            prices: prices,
            discount_rules: discount_rules
          }
        } = changeset,
        _opts,
        _context
      ) do
    options
    |> cartesian_product()
    |> Enum.map(fn combination ->
      prices =
        if is_list(prices),
          do:
            prices
            |> Enum.map(fn %{money: money} ->
              %{money: %{amount: money.amount, currency: money.currency}}
            end),
          else: []

      EatsbotCore.Products.Variant
      |> Ash.Changeset.for_create(
        :create,
        %{
          option_value_ids: combination |> Enum.map(& &1.id),
          name: name,
          description: description,
          sku: sku,
          discount_rules: discount_rules
        },
        authorize?: false
      )
      |> Ash.Changeset.manage_relationship(:product, %{id: changeset.data.id}, type: :append)
      |> Ash.Changeset.manage_relationship(:option_values, combination, type: :append)
      |> Ash.Changeset.manage_relationship(:prices, prices,
        on_no_match: {:create, :create_for_variant},
        on_match: :ignore
      )
      # TODO add error handling and transaction logic. check for_create validation before committing changeset
      |> Ash.create!()
    end)

    changeset
  end

  # gets all the possible value combinations
  defp cartesian_product(list) do
    Enum.reduce(list, [[]], fn option, acc ->
      for combination <- acc, value <- option.option_values, do: [value | combination]
    end)
  end
end
