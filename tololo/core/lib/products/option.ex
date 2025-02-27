defmodule TololoCore.Products.Option do
  # @moduledoc """

  # """
  use Ash.Resource,
    otp_app: :tololo,
    domain: TololoCore.Products,
    extensions: [AshGraphql.Resource, AshAdmin.Resource],
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    notifiers: [Ash.Notifier.PubSub, TololoCore.Kafka.AshNotifier]

  graphql do
    type :product_option
  end

  postgres do
    table "options"
    repo Tololo.Repo
  end

  field_policies do
    field_policy :* do
      description "the rest of the fields don't require any special policies"
      authorize_if always()
    end
  end

  code_interface do
    define :add_value, args: [:value]
  end

  actions do
    defaults [:read, :destroy, update: :*]

    create :create do
      primary? true
      upsert? true
      upsert_identity :unique_option
      accept :*
    end

    update :add_value do
      require_atomic? false
      argument :value, :string, allow_nil?: false

      change fn %{arguments: %{value: value}} = changeset, _context ->
        changeset
        |> Ash.Changeset.manage_relationship(:option_values, %{value: value}, type: :create)
      end
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

    timestamps()
  end

  relationships do
    belongs_to :product, TololoCore.Products.Product do
      public? true
    end

    has_many :option_values, TololoCore.Products.OptionValue do
      public? true
    end

    many_to_many :products, TololoCore.Products.Product do
      public? true
      through TololoCore.Products.ProductOption
    end
  end

  identities do
    identity :unique_option, [:name, :product_id]
  end
end
