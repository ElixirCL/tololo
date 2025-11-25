defmodule EatsbotCore.Carts.DiscountsCalculation do
  @moduledoc """
  Discounts logic for the product management system. Includes an Ash calculation and a discount engine. Returns the lowest price after applying rules instead of combining rules. Returns normal price if there's no applicable rules.
  """
  use Ash.Resource.Calculation
  require Logger

  @impl true
  def load(_query, _opts, _context),
    do: [cart: [:currency], variant: [:discount_rules, prices: [:currency, :money]]]

  @impl true
  def calculate(cart_lines, _opts, _atom) do
    Enum.map(cart_lines, fn %{variant: %{discount_rules: rules}, quantity: quantity} = cart_line ->
      normal_price = get_normal_price(cart_line)

      applicable_prices =
        rules
        |> Enum.map(fn rule ->
          {rule_applies?(rule, cart_line), rule}
        end)
        |> Enum.filter(fn {applies, _rule} -> applies end)
        |> Enum.map(fn {_, rule} -> apply_rule(rule, cart_line, normal_price) end)

      price =
        if Enum.empty?(applicable_prices) do
          normal_price
        else
          Enum.min(applicable_prices, &(Money.compare(&1, &2) != :gt))
        end

      Money.mult!(price, quantity)
    end)
  end

  defp get_normal_price(%{cart: %{currency: currency}, variant: %{prices: prices}}),
    do: Enum.find(prices, &(&1.currency == currency)) |> Map.get(:money)

  defp apply_rule(
         %{method: :fixed, discount: discount},
         %{cart: %{currency: currency}},
         _normal_price
       ),
       do: Money.new!(currency, discount)

  defp apply_rule(%{method: :percentage, discount: discount}, _cart_line, normal_price),
    do: Money.mult!(normal_price, Decimal.sub(1, discount))

  defp apply_rule(
         %{
           method: :x_for_y,
           method_data: %{"buy_x" => buy_x, "for_price_of_y" => for_price_of_y}
         },
         %{quantity: quantity} = cart_line,
         normal_price
       ) do
    # quantity of complete bundles that can be formed
    bundles = div(quantity, buy_x)
    remainder = rem(quantity, buy_x)

    # each bundle costs the price of Y items
    bundle_price = Money.mult!(normal_price, for_price_of_y)

    if bundles > 0 do
      bundle_total = Money.mult!(bundle_price, bundles)
      remainder_total = Money.mult!(normal_price, remainder)

      total_price = Money.add!(bundle_total, remainder_total)

      # converted to per-item price so it can be multiplied by quantity later
      Money.div!(total_price, quantity)
    else
      normal_price
    end
  end

  defp apply_rule(
         %{
           method: :x_for_fixed_price,
           method_data: %{"quantity_x" => quantity_x},
           discount: discount
         },
         %{cart: %{currency: currency}, quantity: line_quantity},
         normal_price
       ) do
    bundles = div(line_quantity, quantity_x)
    remainder = rem(line_quantity, quantity_x)

    bundle_price = Money.new!(currency, discount)

    if bundles > 0 do
      bundle_total = Money.mult!(bundle_price, bundles)
      remainder_total = Money.mult!(normal_price, remainder)

      total_price = Money.add!(bundle_total, remainder_total)

      Money.div!(total_price, line_quantity)
    else
      normal_price
    end
  end

  defp rule_applies?(%{enabled: false}, _cart_line),
    do: false

  defp rule_applies?(%{conditions: []}, _cart_line),
    do: true

  defp rule_applies?(%{conditions: conditions}, cart_line),
    do: Enum.all?(conditions, &condition_applies?(&1, cart_line))

  defp rule_applies?(%{method: :x_for_y, method_data: %{"buy_x" => buy_x}}, %{quantity: quantity})
       when quantity >= buy_x,
       do: true

  defp rule_applies?(%{method_data: %{"buy_x" => buy_x}}, _cart_line),
    do: false

  defp rule_applies?(%{method: :x_for_fixed_price, method_data: %{"quantity_x" => quantity_x}}, %{
         quantity: quantity
       })
       when quantity >= quantity_x,
       do: true

  defp rule_applies?(%{method: :x_for_fixed_price}, %{quantity: quantity}),
    do: true

  defp rule_applies?(rule, _cart_line) do
    Logger.error("Got unmatched rule #{inspect(rule)}")
    false
  end

  defp condition_applies?(%{"from_hour" => from_hour, "to_hour" => to_hour}, _cart_line) do
    current_hour = NaiveDateTime.local_now().hour
    current_hour in from_hour..to_hour
  end

  defp condition_applies?(%{"weekdays" => weekdays}, _cart_line) do
    current_day = Date.day_of_week(Date.utc_today())
    current_day in weekdays
  end

  defp condition_applies?(%{"more_than" => more_than}, %{quantity: line_quantity}) do
    line_quantity > more_than
  end

  defp condition_applies?(condition, _cart_line) do
    Logger.error("Got unmatched condition #{inspect(condition)}")
    false
  end
end
