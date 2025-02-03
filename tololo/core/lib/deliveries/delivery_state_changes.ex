defmodule TololoCore.Deliveries.DeliveryStateChanges do
  @moduledoc """
  Resource that stores the state changes of a delivery.
  """
  use Ash.Resource,
    otp_app: :tololo,
    domain: TololoCore.Deliveries,
    extensions: [AshGraphql.Resource],
    data_layer: AshPostgres.DataLayer

  graphql do
    type :delivery_state_changes
  end

  postgres do
    table "delivery_state_changes"
    repo Tololo.Repo
  end

  code_interface do
    define :add_to_state_history,
      args: [:delivery_id, :old_state, :new_state, :comment],
      action: :create
  end

  actions do
    defaults [:read, :create, :destroy]
    default_accept [:delivery_id, :old_state, :new_state, :comment]
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
    belongs_to :delivery, TololoCore.Deliveries.Delivery
  end
end
