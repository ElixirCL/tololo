defmodule EatsbotCore.Products.CollectionProduct do
  @moduledoc """
  Join resource for the collections and products many_to_many relationship.
  """
  use Ash.Resource,
    domain: EatsbotCore.Products,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "collection_product"
    repo Eatsbot.Repo
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

    belongs_to :collection, EatsbotCore.Products.Collection do
      primary_key? true
      allow_nil? false
      public? true
    end
  end
end
