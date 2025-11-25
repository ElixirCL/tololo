defmodule EatsbotCore.Deliveries.Actors do
  @moduledoc """
  Defines actors used in the Deliveries domain.
  """
  def admin, do: %{access_level: :admin}
  def private, do: %{access_level: :private}
  def public, do: %{access_level: :public}
end
