import Config
config :tololo,
  token_signing_secret: "qg2uHtVokJGsJZ0hdFsoOQlYbDOyeEB0",
  req_impl: Tololo.RequestStub
  
config :ash, disable_async?: true

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :tololo, Tololo.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "tololo_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :tololo, TololoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "qbpNBfHj56JG/dJjuQZmvkAYI084R0kJhx4SKrHodVNMyX5URUsWBAN6rEfVMr1l",
  server: false

# In test we don't send emails
config :tololo, Tololo.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

config :tololo, :kafka_driver, driver: Tololo.Kafka.Noop

config :kafka_ex,
  brokers: [
    {"localhost", 9092},
    {"localhost", 9093}
  ],
  # the default consumer group for worker processes, must be a binary (string)
  #    NOTE if you are on Kafka < 0.8.2 or if you want to disable the use of
  #    consumer groups, set this to :no_consumer_group (this is the
  #    only exception to the requirement that this value be a binary)
  consumer_group: "kafka_ex",
  # The client_id is the logical grouping of a set of kafka clients.
  client_id: "kafka_ex",
  # Set this value to true if you do not want the default
  # `KafkaEx.Server` worker to start during application start-up -
  # i.e., if you want to start your own set of named workers
  disable_default_worker: true,
  # Timeout value, in msec, for synchronous operations (e.g., network calls).
  # If this value is greater than GenServer's default timeout of 5000, it will also
  # be used as the timeout for work dispatched via KafkaEx.Server.call (e.g., KafkaEx.metadata).
  # In those cases, it should be considered a 'total timeout', encompassing both network calls and
  # wait time for the genservers.
  sync_timeout: 3000,
  # Supervision max_restarts - the maximum amount of restarts allowed in a time frame
  max_restarts: 10,
  # Supervision max_seconds -  the time frame in which :max_restarts applies
  max_seconds: 60,
  # Interval in milliseconds that GenConsumer waits to commit offsets.
  commit_interval: 5_000,
  # Threshold number of messages consumed for GenConsumer to commit offsets
  # to the broker.
  commit_threshold: 100,
  # The policy for resetting offsets when an :offset_out_of_range error occurs
  # Options:
  # - `:earliest` - Will move to the offset to the oldest available
  # - `:latest` - Will move the offset to the most recent.
  # - `:none` - The error will simply be raised
  auto_offset_reset: :none,
  # Interval in milliseconds to wait before reconnect to kafka
  sleep_for_reconnect: 400,
  # This is the flag that enables use of ssl
  use_ssl: false,
  # see SSL OPTION DESCRIPTIONS - CLIENT SIDE at http://erlang.org/doc/man/ssl.html
  # for supported options
  # ssl_options: [
  #   # Fix warnings. More at https://github.com/erlang/otp/issues/5352
  #   verify: :verify_none,
  #   cacertfile: File.cwd!() <> "/ssl/ca-cert",
  #   certfile: File.cwd!() <> "/ssl/cert.pem",
  #   keyfile: File.cwd!() <> "/ssl/key.pem"
  # ],
  kafka_version: "0.10.1"
