defmodule Tololo.Deliveries.DeliveryStateChanges do
  use Ash.Resource,
    otp_app: :tololo,
    domain: Tololo.Deliveries,
    extensions: [AshGraphql.Resource],
    data_layer: AshPostgres.DataLayer

  graphql do
    type :delivery_state_changes
  end

  postgres do
    table "delivery_state_changes"
    repo Tololo.Repo
  end

  actions do
    defaults [:read]
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :old_state, :string

    attribute :new_state, :string do
      allow_nil? false
    end

    attribute :comment, :string
    timestamps()
  end

  relationships do
    belongs_to :delivery, Tololo.Deliveries.Delivery
  end
end
