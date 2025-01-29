# This file contains the configuration for Telegram Bot
import Config

config :telegex, token: System.get_env("TELEGRAM_TOKEN") || ""
config :telegex, caller_adapter: Finch
config :telegex, hook_adapter: Bandit

# Note: webhook_url must be a full URL, such as https://your.domain.com/updates_hook, where updates_hook path is fixed.
config :tololo, Tololo.Extensions.TelegramBot.Handler,
  server_port: 4000,
  webhook_url: System.get_env("TELEGRAM_WEBHOOK") || ""
