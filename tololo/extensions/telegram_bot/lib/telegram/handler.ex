defmodule Tololo.Extensions.TelegramBot.Handler do
  require Logger

  @impl true
  def on_boot do
    # read some parameters from your env config
    env_config = Application.get_env(:tololo, __MODULE__)

    # delete the webhook and set it again
    # set the webhook (url is required)
    with {:ok, true} = Telegex.delete_webhook()
    {:ok, true} = Telegex.set_webhook(env_config[:webhook_url])
    do
      Logger.info("Telegram Webhook initialized")
    else
      _ -> Logger.info("Telegram Webhook not set")
    end
  end

  @impl true
  def on_update(update) do
    Logger.debug(update)
    :ok
  end

  @impl true
  def on_failure(update, e) do
    Logger.error("Uncaught Error: #{inspect(update_id: update.update_id, error: e)}")
  end
end
