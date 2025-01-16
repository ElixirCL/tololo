defmodule Tololo.Deliveries.Delivery do
  @moduledoc """
  Represents a delivery of an order in the Tololo system.

  This module defines the `Delivery` resource, which is responsible for managing the state and information related to deliveries within the application. It includes fields for tracking the delivery's state (e.g., 'pending', 'shipped', 'delivered'), and a private authentication key for secure access to delivery data.
  """
  use Ash.Resource,
    otp_app: :tololo,
    domain: Tololo.Deliveries,
    extensions: [AshGraphql.Resource],
    data_layer: AshPostgres.DataLayer

  graphql do
    type :delivery
  end

  postgres do
    table "deliveries"
    repo Tololo.Repo
  end

  code_interface do
    define :update_state, args: [:state], action: :update_state
  end

  actions do
    defaults [:read, :create, :update, :destroy]

    update :update_state do
      accept [:state]
      require_atomic? false

      change Tololo.Deliveries.UpdateHistory
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :state, :string do
      allow_nil? false
    end

    attribute :private_auth_key, :uuid_v7 do
      allow_nil? false
      sensitive? true
    end

    attribute :public_auth_key, :uuid_v7 do
      allow_nil? false
    end

    attribute :delivery_person, :map
    attribute :delivery_order, :map

    attribute :from_latitude, :float do
      sensitive? true
    end

    attribute :from_longitude, :float do
      sensitive? true
    end

    attribute :from_name, :string

    attribute :to_latitude, :float do
      sensitive? true
    end

    attribute :to_longitude, :float do
      sensitive? true
    end

    attribute :to_name, :string

    attribute :to_address, :string do
      sensitive? true
    end

    attribute :to_phone, :string do
      sensitive? true
    end

    attribute :to_notes, :string

    attribute :delivery_started_at, :date
    attribute :delivery_ended_at, :date

    timestamps()
  end
end
