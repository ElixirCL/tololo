defmodule EatsbotCore.Brands.Branch do
  @moduledoc """
  Define the data fields for storing store branch information.
  """

  use Ash.Resource,
    otp_app: :eatsbot,
    domain: EatsbotCore.Brands,
    extensions: [AshGraphql.Resource, AshAdmin.Resource],
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    notifiers: [EatsbotCore.Kafka.AshNotifier]

  use Gettext, backend: EatsbotCore.Gettext
  alias Ash.Changeset

  graphql do
    type :branch

    queries do
      read_one :get_branch, :read
    end

    mutations do
    end
  end

  admin do
  end

  postgres do
    table "branches"
    repo Eatsbot.Repo

    references do
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
    define :update
    define :read, get?: true
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
      sensitive? false
      public? true
    end

    attribute :address, :string do
      allow_nil? false
      sensitive? false
      public? true
    end

    attribute :latitude, :float do
      allow_nil? false
      sensitive? false
      public? true
    end

    attribute :longitude, :float do
      allow_nil? false
      sensitive? false
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :brand, EatsbotCore.Brands.Brand do
      public? true
    end
  end
end
