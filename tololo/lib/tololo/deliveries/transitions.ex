defmodule Tololo.Deliveries.Transitions do
  @moduledoc """
  Functions related to delivery state transitions and comments.
  """

  @state_transitions %{
    {nil, "In_Preparation"} => "La orden está siendo preparada.",
    {"In_Preparation", "In_Delivery"} => "La orden está en tránsito."
    # TODO add all possible states
  }

  @doc """
  Generates a comment for a state transition, based on the old and new state.
  """
  def generate_comment(old_state, new_state),
    do: Map.get(@state_transitions, {old_state, new_state})

  @doc """
  Checks if a state transition is valid.
  """
  def valid?(old_state, new_state),
    do: Map.has_key?(@state_transitions, {old_state, new_state})
end
