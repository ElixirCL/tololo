# This file contains the configuration for Telegram Bot
import Config

config :telegex, token: System.get_env("TELEGRAM_BOT_TOKEN") || ""
config :telegex, caller_adapter: Finch
config :telegex, hook_adapter: Bandit

# Note: webhook_url must be a full URL, such as https://your.domain.com/telegram, where updates_hook path is fixed.
config :eatsbot, Eatsbot.Extensions.TelegramBot.Handler,
  webhook_url: System.get_env("TELEGRAM_WEBHOOK") || ""
