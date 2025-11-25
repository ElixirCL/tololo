defmodule EatsbotCore.Products.ProductOption do
  @moduledoc """
  Join resource for the options and products many_to_many relationship.
  """
  use Ash.Resource,
    domain: EatsbotCore.Products,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "product_option"
    repo Eatsbot.Repo

    references do
      reference :product, on_delete: :delete
      reference :option, on_delete: :delete
    end
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  relationships do
    belongs_to :product, EatsbotCore.Products.Product do
      primary_key? true
      allow_nil? false
      public? true
    end

    belongs_to :option, EatsbotCore.Products.Option do
      primary_key? true
      allow_nil? false
      public? true
    end
  end
end
