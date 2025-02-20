defmodule Tololo.Extensions.TelegramBot.Ash.User do
  @moduledoc """
  Represents a delivery person user in the Telegram bot system. This resource is responsible for handling the state of interactions between the delivery person and the Telegram bot.
  """

  use Ash.Resource,
    otp_app: :tololo,
    domain: Tololo.Extensions.TelegramBot.Ash.Users,
    extensions: [AshAdmin.Resource],
    data_layer: AshPostgres.DataLayer,
    notifiers: [Tololo.Extensions.TelegramBot.Kafka.AshNotifier]

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
    defaults [:read, :destroy, :create]

    default_accept [:id, :status, :deliveries_id]

    read :get_available_users do
      filter expr(status == :allowed)
    end

    update :update do
      primary? true
      require_atomic? false

      change fn changeset, _context ->
        Ash.Changeset.after_transaction(changeset, fn
          _changeset, {:ok, %{status: :allowed} = result} ->
            :telemetry.execute([:ash, :users, :approve], %{count: 1})

            {:ok, result}

          _changeset, {:ok, result} ->
            {:ok, result}

          _changeset, error ->
            error
        end)
      end
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

      change fn changeset, _context ->
        Ash.Changeset.after_transaction(changeset, fn
          _changeset, {:ok, result} ->
            :telemetry.execute([:ash, :users, :delivery, :assigned], %{count: 1})

            {:ok, result}

          _changeset, error ->
            error
        end)
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

defimpl Jason.Encoder, for: TololoCore.Deliveries.Delivery do
  def encode(value, opts) do
    Jason.Encode.map(
      Map.take(value, [
        :id,
        :status,
        :deliveries_id
      ]),
      opts
    )
  end
end
