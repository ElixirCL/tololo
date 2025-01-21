defmodule DeliveryTest do
  alias Tololo.Deliveries

  use Tololo.DataCase, async: true

  @valid_transitions [
    {:Init, :In_Preparation},
    {:Init, :Delivery_Aborted},
    {:In_Preparation, :In_Delivery},
    {:In_Preparation, :Delivery_Aborted},
    {:Delivery_Aborted, :Stale_Delivery_Aborted},
    {:In_Delivery, :Delivery_With_Problems},
    {:In_Delivery, :Delivery_Done},
    {:In_Delivery, :Stale_Delivery_With_Problems},
    {:Delivery_With_Problems, :In_Delivery},
    {:Delivery_With_Problems, :Stale_Delivery_With_Problems},
    {:Delivery_Done, :Stale_Delivery_Done}
  ]

  describe "change delivery state" do
    for {old_state, new_state} <- @valid_transitions do
      test "#{old_state} -> #{new_state}" do
        # https://elixirforum.com/t/parameterized-testing-with-exunit/18935/5
        {old_state, new_state} = {unquote(old_state), unquote(new_state)}

        delivery =
          Deliveries.Delivery
          |> Ash.Changeset.for_create(:create, %{
            delivery_person: %{},
            delivery_order: %{},
            from_name: "from_name",
            to_name: "to_name",
            from_latitude: 100,
            from_longitude: 100,
            to_latitude: 100,
            to_longitude: 100,
            to_address: "to_address",
            to_phone: "to_phone",
            to_notes: "to_notes",
            private_auth_key: Ash.UUIDv7.generate(),
            public_auth_key: Ash.UUIDv7.generate(),
            state: old_state
          })
          |> Ash.create!()
          |> Deliveries.Delivery.update_state!(new_state)

        %{state_history: [%{old_state: os, new_state: ns}]} =
          Ash.load!(delivery, :state_history)

        assert Deliveries.Transitions.equals?(os, old_state) &&
                 Deliveries.Transitions.equals?(ns, new_state)
      end
    end

    test "invalid transition" do
      assert_raise Ash.Error.Invalid, fn ->
        Deliveries.Delivery.empty!() |> Deliveries.Delivery.update_state!(:Delivery_Done)
      end
    end
  end
end
