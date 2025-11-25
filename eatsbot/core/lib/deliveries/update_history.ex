defmodule EatsbotCore.Deliveries.UpdateHistory do
  @moduledoc """
  Checks validity of state transition and also adds it to the state history.
  """

  alias EatsbotCore.Deliveries.Transitions
  alias EatsbotCore.Deliveries.DeliveryStateChanges

  use Ash.Resource.Change
  use Gettext, backend: EatsbotCore.Gettext

  @impl true
  @spec change(Ash.Changeset.t(), term(), term()) :: nil
  def change(changeset, _opts, _context) do
    %{id: id, state: old_state} = changeset.data

    with {:ok, new_state} <- Ash.Changeset.fetch_change(changeset, :state),
         true <- Transitions.valid?(old_state, new_state) do
      comment = Transitions.message(old_state, new_state)

      changeset
      |> Ash.Changeset.after_transaction(fn
        _changeset, {:ok, result} ->
          DeliveryStateChanges.add_to_state_history!(id, old_state, new_state, comment)

          :telemetry.execute([:ash, :deliveries, :update, :state], %{count: 1}, %{
            action: :update_state,
            old_state: old_state,
            new_state: new_state
          })

          {:ok, result}

        _changeset, error ->
          error
      end)
    else
      _ ->
        changeset
        |> Ash.Changeset.add_error(
          field: :state,
          message: gettext("Invalid delivery state transition")
        )
    end
  end
end
