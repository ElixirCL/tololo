defmodule Eatsbot.Repo.Migrations.DeliveriesIndexes do
  @moduledoc """
  Create indexes for public and private auth keys.
  """

  use Ecto.Migration

  def change do
    create index(:deliveries, [:public_auth_key])
    create index(:deliveries, [:private_auth_key])
  end
end
