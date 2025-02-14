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
    table "telegram_bot"
    repo Tololo.Repo
  end

  code_interface do
    define :add_deliveries, args: [:deliveries]
    define :get_available_users
  end

  actions do
    defaults [:read, :destroy, :create, :update]

    default_accept [:id, :status, :deliveries_id]

    read :get_available_users do
      filter expr(status == :allowed)
    end


    update :add_deliveries do
      require_atomic? false

      argument :deliveries, {:array, :uuid} do
        allow_nil? false
      end

      change manage_relationship(:deliveries, type: :append)

      change fn %{data: data, arguments: arguments} = changeset, _context ->
        Ash.Changeset.force_change_attribute(
          changeset,
          :deliveries_id,
          data.deliveries_id ++ arguments.deliveries
        )
      end
    end
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

    relationships do
      has_many :deliveries, TololoCore.Deliveries.Delivery do
        no_attributes? true

        filter expr(id in parent(deliveries_id) and state == :In_Delivery)
      end
    end

    attribute :deliveries_id, {:array, :uuid} do
      public? true
    end

    timestamps()
  end
end
