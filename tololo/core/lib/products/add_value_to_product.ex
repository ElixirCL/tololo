defmodule TololoCore.Products.AddValueToProduct do
  use Ash.Resource.ManualUpdate

  def update(%{arguments: %{option: option, value: value}} = changeset, _, _) do
    with {:ok, %{options: options} = record} <- changeset |> ensure_option_exists(option),
         option_record when not is_nil(option_record) <- Enum.find(options, &(&1.name == option)),
         {:ok, _} <-
           TololoCore.Products.Option.add_value(option_record, %{value: value}, authorize?: false) do
      {:ok, record}
    else
      nil -> {:error, :option_not_found}
      {:error, error} -> {:error, error}
    end
  end

  defp ensure_option_exists(changeset, option) do
    changeset
    |> Ash.Changeset.manage_relationship(:options, %{name: option}, type: :create)
    |> Ash.Changeset.load(:options)
    |> Ash.update(action: :update)
  end
end
