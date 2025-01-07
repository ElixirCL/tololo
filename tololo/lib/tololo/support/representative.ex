defmodule Tololo.Support.Representative do
  use Ash.Resource, otp_app: :tololo, domain: Tololo.Support, data_layer: AshPostgres.DataLayer

  postgres do
    table "representatives"
    repo Tololo.Repo
  end

  actions do
    defaults [:read, create: [:name]]
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end
  end

  relationships do
    has_many :tickets, Tololo.Support.Ticket do
      public? true
    end
  end
end
