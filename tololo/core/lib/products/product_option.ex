defmodule TololoCore.Products.ProductOption do
  @moduledoc """
  Join resource for the options and products many_to_many relationship.
  """
  use Ash.Resource,
    domain: TololoCore.Products,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "product_option"
    repo Tololo.Repo
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  relationships do
    belongs_to :product, TololoCore.Products.Product do
      primary_key? true
      allow_nil? false
      public? true
    end

    belongs_to :option, TololoCore.Products.Option do
      primary_key? true
      allow_nil? false
      public? true
    end
  end
end
