defmodule TololoCore.Products.Attribute do
  # @moduledoc """

  # """
  use Ash.Resource,
    domain: TololoCore.Products,
    extensions: [AshGraphql.Resource],
    data_layer: :embedded

  graphql do
    type :attributes
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :name, :string, public?: true, allow_nil?: false
    attribute :description, :string, public?: true, allow_nil?: false
    attribute :sort, :integer, public?: true, default: 0
    attribute :handle, :string, public?: true, allow_nil?: false
    attribute :type, :string, public?: true, default: "string"
    attribute :section, :string, public?: true, allow_nil?: false
    attribute :required, :boolean, public?: true, default: false
    attribute :default_value, :string, public?: true
    attribute :configuration, :map, default: %{}

    timestamps()
  end
end
