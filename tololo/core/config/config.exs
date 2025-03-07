import Config
config :ash, known_types: [AshMoney.Types.Money], custom_types: [money: AshMoney.Types.Money]
config :ex_cldr, default_backend: TololoCore.Cldr
import_config "#{config_env()}.exs"
