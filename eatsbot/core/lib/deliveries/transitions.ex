defmodule EatsbotCore.Deliveries.Transitions do
  use Gettext, backend: EatsbotCore.Gettext

  # Is needed to be a function instead of a module property
  # due to Gettext nature of loading strings at runtime.
  # Otherwise it will load only the default language.
  @moduledoc """
  Functions related to delivery state transitions and comments.
  """
  @spec state_transitions() :: %{required({String.t(), String.t()}) => String.t() | nil}
  def state_transitions(),
    do: %{
      # Init state transitions
      {"Init", "In_Preparation"} => gettext("The order is processing"),
      {"Init", "Delivery_Aborted"} => gettext("The order cannot be fulfilled or expired"),

      # In_Preparation state transitions
      {"In_Preparation", "Ready_To_Pickup"} => gettext("The order is ready for pickup"),
      {"In_Preparation", "Delivery_Aborted"} =>
        gettext("The order was canceled during preparation"),

      # Ready_To_Pickup state transitions
      {"Ready_To_Pickup", "In_Delivery"} =>
        gettext("The order has been picked up and is on the way"),
      {"Ready_To_Pickup", "Delivery_Aborted"} =>
        gettext("The order was canceled before pick up."),

      # Delivery_Aborted state transitions
      {"Delivery_Aborted", "Stale_Delivery_Aborted"} =>
        gettext("The order was canceled and is now stale"),

      # In_Delivery state transitions
      {"In_Delivery", "Delivery_With_Problems"} =>
        gettext("The delivery has issues, such as address or details mismatch"),
      {"In_Delivery", "Delivery_Done"} => gettext("The delivery has been completed"),
      {"In_Delivery", "Stale_Delivery_With_Problems"} =>
        gettext("The delivery has issues and was not resolved in time"),

      # Delivery_With_Problems state transitions
      {"Delivery_With_Problems", "In_Delivery"} => gettext("Delivery issue resolved"),
      {"Delivery_With_Problems", "Stale_Delivery_With_Problems"} =>
        gettext("The delivery issue was not resolved in time and is now stale"),

      # Delivery_Done state transitions
      {"Delivery_Done", "Stale_Delivery_Done"} => gettext("The completed delivery is now stale")
    }

  @doc """
  Uses gettext to get the translated string for a state.
  """
  @spec get_state_string(String.t()) :: String.t()
  def get_state_string("Init"), do: gettext("Init")
  def get_state_string("In_Preparation"), do: gettext("In_Preparation")
  def get_state_string("Delivery_Aborted"), do: gettext("Delivery_Aborted")
  def get_state_string("Ready_To_Pickup"), do: gettext("Ready_To_Pickup")
  def get_state_string("In_Delivery"), do: gettext("In_Delivery")
  def get_state_string("Stale_Delivery_Aborted"), do: gettext("Stale_Delivery_Aborted")
  def get_state_string("Delivery_With_Problems"), do: gettext("Delivery_With_Problems")
  def get_state_string("Delivery_Done"), do: gettext("Delivery_Done")

  def get_state_string("Stale_Delivery_With_Problems"),
    do: gettext("Stale_Delivery_With_Problems")

  def get_state_string("Stale_Delivery_Done"), do: gettext("Stale_Delivery_Done")
  def get_state_string(_), do: gettext("Invalid_State")

  @doc """
  Generates a comment for a state transition, based on the old and new state.
  """
  @spec message(atom(), atom()) :: String.t()
  def message(old_state, new_state),
    do: Map.get(state_transitions(), {to_string(old_state), to_string(new_state)})

  @doc """
  Returns true if the state is equals to the value.
  """
  @spec equals?(String.t(), atom()) :: boolean()
  def equals?(state, value),
    do: state == to_string(value)

  @doc """
  Checks if a state transition is valid.
  """
  @spec valid?(String.t(), String.t()) :: boolean()
  def valid?(old_state, new_state),
    do: Map.has_key?(state_transitions(), {to_string(old_state), to_string(new_state)})

  @doc """
  Gets a list of states a current_state can transition to.
  """
  @spec get_possible_states(atom()) :: list(String.t())
  def get_possible_states(current_state) do
    current_state = to_string(current_state)

    state_transitions()
    |> Enum.filter(fn state_data -> match?({{^current_state, _}, _}, state_data) end)
    # extract only the target state
    |> Enum.map(fn state_data -> state_data |> elem(0) |> elem(1) end)
    # remove stale states
    |> Enum.reject(fn state -> String.contains?(state, "Stale") end)
    # add i18n
    |> Enum.reduce(%{}, fn state, acc -> Map.put(acc, get_state_string(state), state) end)
  end
end
