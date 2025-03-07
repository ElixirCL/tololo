defmodule TololoCore.Carts.TotalCalculation do
  @moduledoc """
  Calculation for cart total.
  """
  use Ash.Resource.Calculation

  @impl true
  def load(_query, _opts, _context),
    do: [cart_lines: [:subtotal]]

  @impl true
  def calculate(carts, opts, _atom) do
    Enum.map(carts, fn %{cart_lines: cart_lines} = cart ->
      {:ok, result} =
        cart_lines |> Enum.map(fn cart_line -> cart_line.subtotal end) |> Money.sum()

      result
    end)
  end

  defp get_normal_price(%{cart: %{currency: currency}, variant: %{prices: prices}}),
    do: Enum.find(prices, &(&1.currency == currency)) |> Map.get(:money)

  defp calculate_price(discount, %{cart: %{currency: currency}}, :fixed),
    do: Money.new!(currency, discount)

  defp calculate_price(discount, cart_line, :percentage),
    do: Money.mult!(get_normal_price(cart_line), 1 - discount)

  def handle_rule(
        %{
          type: :manual,
          method: method,
          data: %{enabled: true, discount: discount}
        },
        cart_line
      ),
      do: calculate_price(discount, cart_line, method)

  def handle_rule(
        %{
          type: :manual,
          data: %{enabled: false, discount: discount}
        },
        cart_line
      ),
      do: get_normal_price(cart_line)

  # weekday is an int starting from 1, where 1 = monday, 2 = tuesday, etc.
  def handle_rule(
        %{
          type: :weekly,
          method: method,
          data: %{
            weekdays: weekdays,
            discount: discount,
            from_hour: from_hour,
            to_hour: to_hour
          }
        },
        cart_line
      ) do
    current_day = Date.day_of_week(Date.utc_today())
    current_hour = NaiveDateTime.local_now().hour

    if current_day in weekdays and current_hour in from_hour..to_hour,
      do: calculate_price(discount, cart_line, method),
      else: get_normal_price(cart_line)
  end

  def handle_rule(
        %{
          type: :weekly,
          method: method,
          data: %{weekdays: weekdays, discount: discount}
        },
        cart_line
      ) do
    if Date.day_of_week(Date.utc_today()) in weekdays,
      do: calculate_price(discount, cart_line, method),
      else: get_normal_price(cart_line)
  end

  def handle_rule(
        %{
          type: :quantity,
          method: method,
          data: %{more_than: more_than, discount: discount}
        },
        %{quantity: line_quantity} = cart_line
      )
      when line_quantity > more_than,
      do: calculate_price(discount, cart_line, method)

  def handle_rule(
        %{type: :quantity, data: %{more_than: more_than, discount: discount}},
        %{quantity: _line_quantity} = cart_line
      ),
      do: get_normal_price(cart_line)
end
