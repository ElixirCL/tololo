defmodule Tololo.Extensions.TelegramBot.Store do
  @table_name :telegram_bot_state

  def init do
    :ets.new(@table_name, [:set, :public, :named_table])
  end

  @doc """
  Sets the delivery token for a delivery. It will be used to find the Delivery resource that will be updated using the user's live location.
  """
  def set_delivery_token(user_id, token) do
    :ets.insert(@table_name, {{:state, user_id}, token})
  end

  def unset_delivery_token(user_id, token) do
    :ets.delete(@table_name, {:state, user_id})
  end

  def get_delivery_token(user_id) do
    case :ets.lookup(@table_name, {:state, user_id}) do
      [{{:state, _id}, value}] -> {:ok, value}
      [] -> {:error, :not_found}
    end
  end
end
