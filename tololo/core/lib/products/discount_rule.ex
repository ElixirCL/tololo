defmodule TololoCore.Products.DiscountRule do
  # @moduledoc """

  # """
  use Ash.Resource,
    domain: TololoCore.Products,
    extensions: [AshGraphql.Resource],
    data_layer: :embedded

  graphql do
    type :attributes
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :method, :atom do
      public? true
      allow_nil? false
      constraints one_of: [:fixed, :percentage, :x_for_y, :x_for_fixed_price]
    end

    attribute :method_data, :map do
      public? true
      default %{}
    end

    attribute :discount, :decimal, public?: true
    attribute :enabled, :boolean, public?: true, default: true
    attribute :conditions, {:array, :map}, public?: true, default: []

    # attribute :currencies | TODO make rules specific to currencies. if no currencies are provided, it applies to all of them
  end
end
