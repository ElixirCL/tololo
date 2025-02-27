defmodule TololoCore.Products.OptionValue do
  # @moduledoc """

  # """
  use Ash.Resource,
    otp_app: :tololo,
    domain: TololoCore.Products,
    extensions: [AshGraphql.Resource, AshAdmin.Resource],
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    notifiers: [TololoCore.Kafka.AshNotifier]

  graphql do
    type :option_value
  end

  postgres do
    table "option_values"
    repo Tololo.Repo
  end

  field_policies do
    field_policy :* do
      description "the rest of the fields don't require any special policies"
      authorize_if always()
    end
  end

  code_interface do
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

    attribute :value, :string do
      allow_nil? false
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :option, TololoCore.Products.Option do
      public? true
    end

    belongs_to :variant, TololoCore.Products.Variant do
      public? true
    end

    identities do
      identity :unique_value, [:value, :option_id]
    end
  end
end
