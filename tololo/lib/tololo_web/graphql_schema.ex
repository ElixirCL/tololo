defmodule TololoWeb.GraphqlSchema do
  @moduledoc """
  Schema for GraphQL endpoints.
  """
  use Absinthe.Schema

  use AshGraphql,
    domains: [TololoCore.Deliveries],
    generate_sdl_file: "priv/schema.graphql"

  import_types Absinthe.Plug.Types

  query do
    # Custom Absinthe queries can be placed here
    @desc """
    Hello! This is a sample query to verify that AshGraphql has been set up correctly.
    Remove me once you have a query of your own!
    """
    field :say_hello, :string do
      resolve fn _, _, _ ->
        {:ok, "Hello from AshGraphql!"}
      end
    end
  end

  object :money do
    field(:amount, non_null(:decimal))
    field(:currency, non_null(:string))
  end

  input_object :money_input do
    field(:amount, non_null(:decimal))
    field(:currency, non_null(:string))
  end

  mutation do
    # Custom Absinthe mutations can be placed here
  end

  subscription do
    # Custom Absinthe subscriptions can be placed here
  end
end
