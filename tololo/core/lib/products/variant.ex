defmodule TololoCore.Products.Variant do
  # @moduledoc """
  # Represents a delivery of an order in the Tololo system.

  # This module defines the `Delivery` resource, which is responsible for managing the state and information related to deliveries within the application. It includes fields for tracking the delivery's state (e.g., 'pending', 'shipped', 'delivered'), and a private authentication key for secure access to delivery data.
  # """
  use Ash.Resource,
    otp_app: :tololo,
    domain: TololoCore.Products,
    extensions: [AshGraphql.Resource, AshAdmin.Resource],
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    notifiers: [TololoCore.Kafka.AshNotifier]

  alias Ash.Changeset

  graphql do
    type :variant

    queries do
      get :get_variant, :read
    end

    mutations do
    end
  end

  admin do
  end

  postgres do
    table "variants"
    repo Tololo.Repo

    references do
      reference :product, on_delete: :delete
    end
  end

  field_policies do
    field_policy :* do
      description "the rest of the fields don't require any special policies"
      authorize_if always()
    end
  end

  code_interface do
    define :create
    define :update_price, args: [:money]
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]

    update :update_price do
      require_atomic? false
      argument :money, :money, allow_nil?: false

      change fn %{arguments: %{money: money}} = changeset, _context ->
        changeset
        |> Changeset.manage_relationship(:prices, [%{money: money}],
          on_no_match: {:create, :create_for_variant},
          on_match: :ignore
        )
      end

      change load(:prices)
    end
  end

  policies do
    bypass always() do
      description "admin has access to every action"
      authorize_if actor_attribute_equals(:access_level, :admin)
    end

    policy action_type(:read) do
      description "read access is always allowed"
      authorize_if always()
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :description, :string do
      public? true
    end

    attribute :sku, :string do
      allow_nil? false
      public? true
    end

    attribute :images, {:array, :string} do
      public? true
    end

    attribute :attributes, {:array, TololoCore.Products.Attribute}, public?: true

    attribute :option_value_ids, {:array, :string},
      public?: true,
      description: "needed for identity"

    timestamps()
  end

  relationships do
    has_many :prices, TololoCore.Products.Price, public?: true

    belongs_to :product, TololoCore.Products.Product, public?: true

    # the option values this variant represents
    many_to_many :option_values, TololoCore.Products.OptionValue do
      through TololoCore.Products.VariantOption
      source_attribute_on_join_resource :variant_id
      destination_attribute_on_join_resource :option_value_id
      public? true
    end
  end

  identities do
    identity :unique_variant, [:option_value_ids, :product_id]
  end
end
