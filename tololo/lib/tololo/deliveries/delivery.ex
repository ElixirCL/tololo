defmodule Tololo.Deliveries.Delivery do
  @moduledoc """
  Represents a delivery of an order in the Tololo system.

  This module defines the `Delivery` resource, which is responsible for managing the state and information related to deliveries within the application. It includes fields for tracking the delivery's state (e.g., 'pending', 'shipped', 'delivered'), and a private authentication key for secure access to delivery data.
  """
  use Ash.Resource,
    otp_app: :tololo,
    domain: Tololo.Deliveries,
    extensions: [AshGraphql.Resource],
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  graphql do
    type :delivery

    queries do
      get :get_delivery, :read
    end

    mutations do
      create :init_delivery, :initialize
      update :update_state, :update_state
      update :update_location, :update_location
    end

    # required for making fields forbidden
    nullable_fields [
      :private_auth_key,
      :public_auth_key
    ]
  end

  postgres do
    table "deliveries"
    repo Tololo.Repo
  end

  field_policies do
    field_policy :private_auth_key do
      description "public auth key should only be visible to admin"
      authorize_if actor_attribute_equals(:access_level, :admin)
    end

    field_policy :public_auth_key do
      description "private auth key should only be visible to admin"
      authorize_if actor_attribute_equals(:access_level, :admin)
    end

    field_policy :* do
      description "the rest of the fields don't require any special policies"
      authorize_if always()
    end
  end

  code_interface do
    define :update_state, args: [:state], action: :update_state
    define :initialize, action: :initialize
    define :empty, action: :empty
    define :get_via_token, args: [:token], action: :get_via_token
    define :update_location, args: [:from_latitude, :from_longitude], action: :update_location
  end

  actions do
    defaults [:read, :update, :destroy]

    read :get_via_token do
      argument :token, :string

      filter expr(public_auth_key == ^arg(:token) or private_auth_key == ^arg(:token))
    end

    create :create do
      accept [
        :delivery_person,
        :delivery_order,
        :from_name,
        :to_name,
        :from_latitude,
        :from_longitude,
        :to_latitude,
        :to_longitude,
        :to_address,
        :to_phone,
        :to_notes,
        :state,
        :private_auth_key,
        :public_auth_key
      ]
    end

    create :initialize do
      accept [
        :delivery_person,
        :delivery_order,
        :from_name,
        :to_name,
        :from_latitude,
        :from_longitude,
        :to_latitude,
        :to_longitude,
        :to_address,
        :to_phone,
        :to_notes
      ]

      change set_attribute(:state, :Init)
      change set_attribute(:private_auth_key, Ash.UUIDv7.generate())
      change set_attribute(:public_auth_key, Ash.UUIDv7.generate())
    end

    create :empty do
      accept []

      change set_attribute(:delivery_person, %{})
      change set_attribute(:delivery_order, %{})
      change set_attribute(:from_name, "")
      change set_attribute(:to_name, "")
      change set_attribute(:from_latitude, 100)
      change set_attribute(:from_longitude, 100)
      change set_attribute(:to_latitude, 100)
      change set_attribute(:to_longitude, 100)
      change set_attribute(:to_address, "")
      change set_attribute(:to_phone, "")
      change set_attribute(:to_notes, "")
      change set_attribute(:state, :Init)
      change set_attribute(:private_auth_key, Ash.UUIDv7.generate())
      change set_attribute(:public_auth_key, Ash.UUIDv7.generate())
    end

    update :update_state do
      accept [:state]
      require_atomic? false

      change Tololo.Deliveries.UpdateHistory
    end

    update :update_location do
      accept [:from_latitude, :from_longitude]
    end
  end

  policies do
    bypass always() do
      description "admin has access to every action"
      authorize_if actor_attribute_equals(:access_level, :admin)
    end

    policy action_type(:read) do
      description "read access is limited to users with public and private access"
      authorize_if actor_attribute_equals(:access_level, :public)
      authorize_if actor_attribute_equals(:access_level, :private)
    end

    policy action_type(:update) do
      description "update access is limited to users private access"
      authorize_if actor_attribute_equals(:access_level, :private)
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :state, :string do
      allow_nil? false
      public? true
    end

    attribute :private_auth_key, :uuid_v7 do
      allow_nil? false
      sensitive? true
      public? true
    end

    attribute :public_auth_key, :uuid_v7 do
      allow_nil? false
      public? true
    end

    attribute :delivery_person, :map do
      public? true
    end

    attribute :delivery_order, :map do
      public? true
    end

    attribute :from_latitude, :float do
      sensitive? true
      public? true
    end

    attribute :from_longitude, :float do
      sensitive? true
      public? true
    end

    attribute :from_name, :string do
      public? true
    end

    attribute :to_latitude, :float do
      sensitive? true
      public? true
    end

    attribute :to_longitude, :float do
      sensitive? true
      public? true
    end

    attribute :to_name, :string do
      public? true
    end

    attribute :to_address, :string do
      sensitive? true
      public? true
    end

    attribute :to_phone, :string do
      sensitive? true
      public? true
    end

    attribute :to_notes, :string do
      public? true
    end

    attribute :delivery_started_at, :date do
      public? true
    end

    attribute :delivery_ended_at, :date do
      public? true
    end

    timestamps()
  end

  relationships do
    has_many :state_history, Tololo.Deliveries.DeliveryStateChanges
  end
end
