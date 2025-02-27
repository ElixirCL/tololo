defmodule TololoCore.Carts.Cart do
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
    type :cart
  end

  postgres do
    table "carts"
    repo Tololo.Repo
  end

  field_policies do
    field_policy :* do
      description "the rest of the fields don't require any special policies"
      authorize_if always()
    end
  end

  code_interface do
    define :create
    define :add_variant, args: [:variant, {:optional, :quantity}, {:optional, :notes}]
    define :checkout_delivery, args: [:cart, :delivery_input]
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]

    action :checkout_delivery, :term do
      argument :cart, :term, allow_nil?: false
      argument :delivery_input, :map, allow_nil?: false

      run fn %{arguments: %{cart: cart, delivery_input: delivery_input}}, _ ->
        TololoCore.Deliveries.Delivery.initialize(
          %{delivery_input | delivery_order: cart_to_map(cart)},
          authorize?: false
        )
      end
    end

    update :add_variant do
      require_atomic? false
      argument :variant, :struct, allow_nil?: false
      argument :quantity, :integer, default: 1
      argument :notes, :string, default: nil

      validate fn %{data: %{currency: currency}, arguments: %{variant: %{prices: prices}}} =
                    changeset,
                  _context ->
        prices = Ash.load!(prices, :currency, lazy?: true, reuse_values?: true)

        if Enum.any?(prices, fn price -> price.currency == currency end) do
          :ok
        else
          {:error, field: :variant, message: "must have a price for #{currency}"}
        end
      end

      change fn %{arguments: %{variant: variant, quantity: quantity, notes: notes}} = changeset,
                _context ->
        changeset
        |> Ash.Changeset.manage_relationship(
          :cart_lines,
          %{variant_id: variant.id, quantity: quantity, notes: notes},
          type: :create
        )
      end

      change load([
               :total,
               :total_before_discount,
               cart_lines: [:variant, :subtotal, :subtotal_before_discount]
             ])
    end
  end

  policies do
    bypass always() do
      authorize_if always()
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :status, :atom do
      constraints one_of: [:active, :completed, :abandoned]
      public? true
      default :active
    end

    attribute :currency, :string do
      public? true
      # TODO use store config
      default "CLP"
    end

    timestamps()
  end

  relationships do
    has_many :cart_lines, TololoCore.Carts.CartLine do
      public? true
    end
  end

  calculations do
    calculate :total,
              :money,
              TololoCore.Carts.TotalCalculation
  end

  aggregates do
    sum :total_before_discount, [:cart_lines], :subtotal_before_discount
  end

  defp cart_to_map(cart) do
    %{
      cart_id: cart.id,
      cart_lines:
        Enum.map(cart.cart_lines, fn line ->
          %{quantity: line.quantity, name: line.variant.name}
        end)
    }
  end
end
