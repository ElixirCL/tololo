defmodule EatsbotCore.Products.Collection do
  # @moduledoc """
  # Represents a delivery of an order in the Eatsbot system.

  # This module defines the `Delivery` resource, which is responsible for managing the state and information related to deliveries within the application. It includes fields for tracking the delivery's state (e.g., 'pending', 'shipped', 'delivered'), and a private authentication key for secure access to delivery data.
  # """
  use Ash.Resource,
    otp_app: :eatsbot,
    domain: EatsbotCore.Products,
    extensions: [AshGraphql.Resource, AshAdmin.Resource],
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    notifiers: [EatsbotCore.Kafka.AshNotifier]

  use Gettext, backend: EatsbotCore.Gettext

  graphql do
    type :collection

    queries do
      get :get_collection, :read
    end

    mutations do
    end
  end

  admin do
  end

  postgres do
    table "collections"
    repo Eatsbot.Repo

    references do
      # reference :state_history, on_delete: :delete
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
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
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

    attribute :image, :string do
      public? true
    end

    attribute :is_brand, :boolean do
      allow_nil? false
      default(false)
      public? true
    end

    timestamps()
  end

  relationships do
    many_to_many :products, EatsbotCore.Products.Product do
      through EatsbotCore.Products.CollectionProduct
      source_attribute_on_join_resource :product_id
      destination_attribute_on_join_resource :collection_id
    end
  end
end
