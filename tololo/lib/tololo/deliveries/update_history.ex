defmodule Tololo.Deliveries.UpdateHistory do
  @moduledoc """
  Checks validity of state transition and also adds it to the state history.
  """

  alias Tololo.Deliveries.Transitions
  alias Tololo.Deliveries.DeliveryStateChanges

  use Ash.Resource.Change
  use Gettext, backend: TololoWeb.Gettext

  @impl true
  @spec change(Ash.Changeset.t(), term(), term()) :: nil
  def change(changeset, _opts, _context) do
    %{id: id, state: old_state} = changeset.data
    {:ok, new_state} = Ash.Changeset.fetch_change(changeset, :state)

    case Transitions.valid?(old_state, new_state) do
      true ->
        comment = Transitions.message(old_state, new_state)
        DeliveryStateChanges.add_to_state_history!(id, old_state, new_state, comment)

        changeset

      false ->
        changeset
        |> Ash.Changeset.add_error(
          field: :state,
          message: gettext("Invalid delivery state transition")
        )
    end
  end
end
