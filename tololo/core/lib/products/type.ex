defmodule TololoCore.Products.Type do
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
    type :type
  end

  postgres do
    table "types"
    repo Tololo.Repo
  end

  field_policies do
    field_policy :* do
      description "the rest of the fields don't require any special policies"
      authorize_if always()
    end
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

    attribute :attributes, {:array, TololoCore.Products.Attribute} do
      public? true
    end

    timestamps()
  end
end
