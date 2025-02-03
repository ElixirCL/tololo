defmodule Tololo.Extensions.TelegramBot.Handler do
  # TODO: Implement proper docs
  # TODO: Implement telegram bot commands
  @moduledoc false

  alias Tololo.Extensions.TelegramBot

  require Logger

  def on_boot do
    # read some parameters from your env config
    env_config = Application.get_env(:tololo, __MODULE__)

    # delete the webhook and set it again
    # set the webhook (url is required)
    try do
      {:ok, true} = Telegex.delete_webhook()
      {:ok, true} = Telegex.set_webhook(env_config[:webhook_url])
      Logger.info("Telegram Webhook initialized")
    rescue
      _ -> Logger.info("Telegram Webhook not set")
    end
  end

  def on_update(update) do
    TelegramBot.ChainHandler.call(update, %TelegramBot.ChainContext{bot: Telegex.Instance.bot()})
  end

  def on_failure(update, e) do
    Logger.error("Uncaught Error: #{inspect(update_id: update.update_id, error: e)}")
  end
end
