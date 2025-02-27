defmodule TololoCore.Carts.CartLine do
  # @moduledoc """

  # """
  use Ash.Resource,
    otp_app: :tololo,
    domain: TololoCore.Carts,
    extensions: [AshGraphql.Resource],
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    notifiers: [Ash.Notifier.PubSub, TololoCore.Kafka.AshNotifier]

  graphql do
    type :cart_line
  end

  postgres do
    table "cart_lines"
    repo Tololo.Repo
  end

  field_policies do
    field_policy :* do
      description "the rest of the fields don't require any special policies"
      authorize_if always()
    end
  end

  actions do
    defaults [:read, :destroy, update: :*]

    create :create do
      primary? true
      upsert? true
      upsert_identity :unique_variant
      accept :*
    end
  end

  policies do
    bypass always() do
      authorize_if always()
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :quantity, :integer, public?: true, allow_nil?: false, constraints: [min: 0]
    attribute :notes, :string, public?: true

    timestamps()
  end

  relationships do
    belongs_to :variant, TololoCore.Products.Variant, public?: true, allow_nil?: false
    belongs_to :cart, TololoCore.Carts.Cart, public?: true, allow_nil?: false
  end

  calculations do
    calculate :subtotal,
              :money,
              expr(
                first(variant.prices,
                  query: [
                    filter: currency == variant.cart_lines.cart.currency,
                    load: [variant: [cart_lines: [:cart]]]
                  ],
                  field: :money
                ) *
                  quantity
              )
  end

  identities do
    identity :unique_variant, [:variant_id, :cart_id]
  end
end
