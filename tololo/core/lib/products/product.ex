defmodule TololoCore.Products.Product do
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

  use Gettext, backend: TololoCore.Gettext
  alias Ash.Changeset

  graphql do
    type :product

    queries do
      get :get_product, :read
    end

    mutations do
    end
  end

  admin do
  end

  postgres do
    table "products"
    repo Tololo.Repo

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
    define :get_or_create_option, args: [:product, :option]
    define :ensure_option_exists, args: [:option]
    define :add_to_collection, args: [:collection_id]
    define :generate_variants
    define :create
    define :update_price, args: [:money]
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]

    read :get_enabled do
      filter expr(state == :enabled)
    end

    update :generate_variants do
      require_atomic? false

      change fn %{data: data} = changeset, _ ->
        data =
          Ash.load!(
            data,
            [options: [:option_values]],
            lazy?: true
          )

        %{changeset | data: data}
      end

      change TololoCore.Products.Product.VariantGenerator
      change load(variants: [:option_values])
    end

    action :get_or_create_option, :term do
      # return created option using Enum.find
      argument :product, :term, allow_nil?: false
      argument :option, :string, allow_nil?: false

      run fn %{arguments: %{product: product, option: option}}, _ ->
        %{options: options} =
          product =
          product |> TololoCore.Products.Product.ensure_option_exists!(option, authorize?: false)

        option_record = options |> Enum.find(&(&1.name == option))

        {:ok, option_record}
      end
    end

    update :ensure_option_exists do
      require_atomic? false
      argument :option, :string, allow_nil?: false

      change load(:options)

      change fn %{arguments: %{option: option}} = changeset, _context ->
        changeset
        |> Changeset.manage_relationship(:options, %{name: option}, type: :create)
      end
    end

    update :add_to_collection do
      require_atomic? false
      argument :collection_id, :string, allow_nil?: false

      change fn %{arguments: %{collection_id: collection_id}} = changeset, _context ->
        changeset
        |> Changeset.manage_relationship(:collections, [%{id: collection_id}], type: :append)
      end
    end

    update :update_price do
      require_atomic? false
      argument :money, :money, allow_nil?: false

      change fn %{arguments: %{money: money}} = changeset, _context ->
        changeset
        |> Changeset.manage_relationship(:prices, [%{money: money}],
          on_no_match: {:create, :create_for_product},
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

    attribute :name, :string, public?: true, allow_nil?: false
    attribute :description, :string, public?: true, allow_nil?: false
    attribute :sku, :string, public?: true, allow_nil?: false

    attribute :state, :atom do
      constraints one_of: [:disabled, :enabled, :hidden]
      allow_nil? false
      public? true
      default :disabled
    end

    timestamps()
  end

  relationships do
    belongs_to :type, TololoCore.Products.Type do
      public? true
    end

    has_many :prices, TololoCore.Products.Price, public?: true

    many_to_many :collections, TololoCore.Products.Collection do
      through TololoCore.Products.CollectionProduct
      source_attribute_on_join_resource :product_id
      destination_attribute_on_join_resource :collection_id
      public? true
    end

    has_many :variants, TololoCore.Products.Variant do
      public? true
    end

    has_many :options, TololoCore.Products.Option do
      public? true
    end
  end
end
