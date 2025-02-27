defmodule TololoCore.Products.VariantOption do
  @moduledoc """
  Join resource for the variants and options many_to_many relationship.
  """
  use Ash.Resource,
    domain: TololoCore.Products,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "variant_option"
    repo Tololo.Repo
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  relationships do
    belongs_to :variant, TololoCore.Products.Variant do
      primary_key? true
      allow_nil? false
      public? true
    end

    belongs_to :option_value, TololoCore.Products.OptionValue do
      primary_key? true
      allow_nil? false
      public? true
    end
  end
end
