defmodule Tololo.Deliveries.UpdateHistory do
  @moduledoc """
  Checks validity of state transition and also adds it to the state history.
  """

  use Ash.Resource.Change
  use Gettext, backend: TololoWeb.Gettext

  alias Tololo.Deliveries.DeliveryStateChanges
  alias Tololo.Deliveries.Transitions

  @impl true
  @spec change(Ash.Changeset.t(), term(), term()) :: nil
  def change(changeset, _opts, _context) do
    %{id: id, state: old_state} = changeset.data

    with {:ok, new_state} <- Ash.Changeset.fetch_change(changeset, :state),
         true <- Transitions.valid?(old_state, new_state) do
      comment = Transitions.message(old_state, new_state)
      DeliveryStateChanges.add_to_state_history!(id, old_state, new_state, comment)

      changeset
    else
      _ ->
        Ash.Changeset.add_error(changeset,
          field: :state,
          message: gettext("Invalid delivery state transition")
        )
    end
  end
end
