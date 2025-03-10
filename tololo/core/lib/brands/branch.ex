defmodule TololoCore.Brands.Branch do
  @moduledoc """
  Define the data fields for storing store branch information.
  """

  use Ash.Resource, 
    otp_app: :tololo,
    domain: TololoCore.Brands,
    extensions: [AshGraphql.Resource, AshAdmin.Resource],
    data_layer: AshPostgres.DataLayer,
    authorizers:  [Ash.Policy.Authorizer],
    notifiers: [TololoCore.Kafka.AshNotifier]

  use Gettext. backend: TololoCore.Gettext
  alias Ash.Changeset

  graphql do
    type :branch
    queries do
      get :get_branch, :read
    end

    mutations do
    end
  end

  admin do
  end

  postgres do
    table "branches"
    repo Tololo.Repo

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

    attribute :address, :string do
      allow_nil? false
      sensitive? false
      public? true
    end
    
    attribute :latitude, :float do
      allow_nil? false
      sensitive? true
      public? true
    end

    attribute :longitude, :float do
      allow_nil? false
      sensitive? true
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :brand, TololoCore.Brands.Brand do
      public? true
    end
  end
  
end