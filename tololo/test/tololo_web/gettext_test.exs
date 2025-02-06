defmodule GettextTest do
  @moduledoc """
  Test that Getttext translations are correctly loaded  for English and Spanish.
  """
  alias TololoCore.Deliveries
  alias TololoCore.Deliveries.Transitions

  use Tololo.DataCase, async: true

  describe "delivery state messages" do
    test "that In_Preparation has correct message" do
      delivery =
        Deliveries.Delivery.empty!(authorize?: false)
        |> Deliveries.Delivery.update_state!(:In_Preparation, authorize?: false)

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
