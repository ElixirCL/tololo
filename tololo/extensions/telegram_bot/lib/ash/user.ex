defmodule Tololo.Extensions.TelegramBot.Ash.User do
  @moduledoc """
  Represents a delivery person user in the Telegram bot system. This resource is responsible for handling the state of interactions between the delivery person and the Telegram bot.
  """
  use Ash.Resource,
    otp_app: :tololo,
    domain: Tololo.Extensions.TelegramBot.Ash.Users,
    extensions: [AshAdmin.Resource],
    data_layer: AshPostgres.DataLayer

  admin do
  end

  postgres do
    table "deliveries"
    repo Tololo.Repo
  end

  code_interface do
  end

  actions do
  end

  attributes do
    attribute :id, :string do
      allow_nil? false
      primary_key? true
    end

    attribute :status, :atom do
      allow_nil? false
      public? true
    end

    attribute :deliveries, {:array, :string} do
      public? true
    end

    timestamps()
  end
end
