defmodule TololoCore.Deliveries.Delivery do
  @moduledoc """
  Represents a delivery of an order in the Tololo system.

  This module defines the `Delivery` resource, which is responsible for managing the state and information related to deliveries within the application. It includes fields for tracking the delivery's state (e.g., 'pending', 'shipped', 'delivered'), and a private authentication key for secure access to delivery data.
  """
  use Ash.Resource,
    otp_app: :tololo,
    domain: TololoCore.Deliveries,
    extensions: [AshGraphql.Resource, AshAdmin.Resource],
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    notifiers: [Ash.Notifier.PubSub, TololoCore.Kafka.AshNotifier]

  use Gettext, backend: TololoCore.Gettext

  alias TololoCore.Location
  @min_done_distance Application.compile_env(:tololo, :min_done_distance_meters)

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
      :public_auth_key,
      :display_id
    ]
  end

  admin do
    create_actions([:initialize])
    update_actions([:update_state, :update_location])
  end

  admin do
    create_actions([:initialize])
    update_actions([:update_state, :update_location])
  end

  postgres do
    table "deliveries"
    repo Tololo.Repo

    references do
      reference :state_history, on_delete: :delete
    end
  end

  field_policies do
    field_policy :display_id do
      description "display id should only be visible to admin and people with private access"
      authorize_if actor_attribute_equals(:access_level, :admin)
      authorize_if actor_attribute_equals(:access_level, :private)
    end

    field_policy :private_auth_key do
      description "private auth key should only be visible to admin"
      authorize_if actor_attribute_equals(:access_level, :admin)
    end

    field_policy :public_auth_key do
      description "public auth key should only be visible to admin"
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
    define :get_via_display_id, args: [:display_id], action: :get_via_display_id

    define :update_location,
      args: [:current_latitude, :current_longitude],
      action: :update_location

    define :get_ready_to_pickup
    define :get_pending_stale

    define :update_delivery_person
    define :done_with_distance_check
  end

  actions do
    defaults [:read, :update, :destroy]

    read :get_via_token do
      argument :token, :string

      filter expr(public_auth_key == ^arg(:token) or private_auth_key == ^arg(:token))
    end

    read :get_via_display_id do
      get_by :display_id
    end

    read :get_ready_to_pickup do
      filter expr(state == "Ready_To_Pickup")
    end

    read :get_pending_stale do
      filter expr(state != "Stale_Delivery_Aborted")
      filter expr(state != "Stale_Delivery_With_Problems")
      filter expr(state != "Stale_Delivery_Done")

      days = Application.compile_env(:tololo, :days_for_stale, 2)
      filter expr(inserted_at < ago(^days, :day))
    end

    create :create do
      accept [
        :delivery_person,
        :delivery_order,
        :from_name,
        :to_name,
        :from_latitude,
        :from_longitude,
        :current_latitude,
        :current_longitude,
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
      primary? true

      accept [
        :delivery_person,
        :delivery_order,
        :to_name,
        :to_latitude,
        :to_longitude,
        :to_address,
        :to_phone,
        :to_notes
      ]

      change set_attribute(
               :from_name,
               Application.compile_env(:tololo, :business_name, "A business")
             )

      {lat, lng} = Application.compile_env(:tololo, :from_location, {0, 0})
      change set_attribute(:from_latitude, lat)
      change set_attribute(:from_longitude, lng)
    end

    create :empty do
      accept []

      change set_attribute(:delivery_person, %{})
      change set_attribute(:delivery_order, %{})
      change set_attribute(:from_name, "from")
      change set_attribute(:to_name, "to")
      change set_attribute(:from_latitude, 100)
      change set_attribute(:from_longitude, 100)
      change set_attribute(:current_latitude, 100)
      change set_attribute(:current_longitude, 100)
      change set_attribute(:to_latitude, 100)
      change set_attribute(:to_longitude, 100)
      change set_attribute(:to_address, "address")
      change set_attribute(:to_phone, "")
      change set_attribute(:to_notes, "")
    end

    update :update_state do
      primary? true
      accept [:state]
      require_atomic? false

      change TololoCore.Deliveries.UpdateHistory
    end

    update :update_delivery_person do
      accept [:delivery_person]
    end

    update :update_location do
      accept [:current_latitude, :current_longitude]

      validate attribute_equals(:state, :In_Delivery) do
        message gettext("the state must be in delivery to update the current location")
      end
    end

    update :done_with_distance_check do
      require_atomic? false

      change fn %{
                  data: %{
                    current_latitude: current_lat,
                    current_longitude: current_lng,
                    to_latitude: to_lat,
                    to_longitude: to_lng,
                    state: old_state,
                    id: id
                  }
                } =
                  changeset,
                _context ->
        changeset =
          with true <- current_lat != nil and current_lng != nil,
               distance <- Location.distance({current_lat, current_lng}, {to_lat, to_lng}),
               true <- distance <= @min_done_distance do
            changeset
            |> Ash.Changeset.force_change_attribute(:state, "Delivery_Done")
          else
            _ ->
              changeset
              |> Ash.Changeset.force_change_attribute(:state, "Delivery_With_Problems")
          end

        changeset
        |> Ash.Changeset.after_transaction(fn
          _changeset, {:ok, result} ->
            {:ok, new_state} = Ash.Changeset.fetch_change(changeset, :state)
            comment = TololoCore.Deliveries.Transitions.message(old_state, new_state)

            TololoCore.Deliveries.DeliveryStateChanges.add_to_state_history!(
              id,
              old_state,
              new_state,
              comment
            )

            :telemetry.execute([:ash, :deliveries, :update, :state], %{count: 1}, %{
              action: :done_with_distance_check,
              old_state: old_state,
              new_state: new_state
            })

            {:ok, result}

          _changeset, error ->
            error
        end)
      end
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

  pub_sub do
    module TololoWeb.Endpoint

    prefix "delivery"
    publish :update_location, ["updated", :id]

    publish :update_state, ["updated", :id]
    publish :update_state, ["updated"]

    publish :done_with_distance_check, ["updated", :id]
    publish :done_with_distance_check, ["updated"]
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :display_id, :string do
      default fn -> FriendlyID.generate(3) end
      public? true
    end

    attribute :state, :string do
      allow_nil? false
      public? true
      default :Init
    end

    attribute :private_auth_key, :uuid_v7 do
      allow_nil? false
      sensitive? true
      public? true
      default &Ash.UUIDv7.generate/0
    end

    attribute :public_auth_key, :uuid_v7 do
      allow_nil? false
      public? true
      default &Ash.UUIDv7.generate/0
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

    attribute :current_latitude, :float do
      sensitive? true
      public? true
    end

    attribute :current_longitude, :float do
      sensitive? true
      public? true
    end

    attribute :from_name, :string do
      public? true
    end

    attribute :to_latitude, :float do
      allow_nil? false
      sensitive? true
      public? true
    end

    attribute :to_longitude, :float do
      allow_nil? false
      sensitive? true
      public? true
    end

    attribute :to_name, :string do
      public? true
    end

    attribute :to_address, :string do
      allow_nil? false
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
    has_many :state_history, TololoCore.Deliveries.DeliveryStateChanges do
      public? true
    end
  end
end

defimpl Jason.Encoder, for: TololoCore.Deliveries.Delivery do
  def encode(value, opts) do
    Jason.Encode.map(
      Map.take(value, [
        :id,
        :display_id,
        :delivery_person,
        :delivery_order,
        :from_name,
        :to_name,
        :from_latitude,
        :from_longitude,
        :current_latitude,
        :current_longitude,
        :to_latitude,
        :to_longitude,
        :to_address,
        :to_phone,
        :to_notes,
        :state
      ]),
      opts
    )
  end
end
