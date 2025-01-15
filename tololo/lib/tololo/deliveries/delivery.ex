defmodule Tololo.Deliveries.Delivery do
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

  actions do
    defaults [:read]
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
