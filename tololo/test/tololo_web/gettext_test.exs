defmodule GettextTest do
  @moduledoc """
  Test that Getttext translations are correctly loaded  for English and Spanish.
  """
  use Tololo.DataCase, async: true

  alias Tololo.Deliveries
  alias Tololo.Deliveries.Transitions

  describe "delivery state messages" do
    test "that In_Preparation has correct message" do
      delivery = Deliveries.Delivery.update_state!(Deliveries.Delivery.empty!(), :In_Preparation)

      %{state_history: [%{old_state: old_state, new_state: new_state}]} =
        Ash.load!(delivery, :state_history)

      # Default Message
      message = Transitions.message(old_state, new_state)
      assert message == "The order is processing"

      # English Message
      Gettext.with_locale("en", fn ->
        message = Transitions.message(old_state, new_state)
        assert message == "The order is processing"
      end)

      # Spanish Message
      Gettext.with_locale("es", fn ->
        message = Transitions.message(old_state, new_state)
        assert message == "La orden está en preparación"
      end)
    end
  end
end
