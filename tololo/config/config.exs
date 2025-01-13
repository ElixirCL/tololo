# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :ash,
  allow_forbidden_field_for_relationships_by_default?: true,
  include_embedded_source_by_default?: false,
  show_keysets_for_all_actions?: false,
  default_page_type: :keyset,
  policies: [no_filter_static_forbidden_reads?: false],
  custom_types: [ticket_status: Tololo.Support.Ticket.Types.Status]

config :spark,
  formatter: [
    remove_parens?: true,
    "Ash.Resource": [
      section_order: [
        :postgres,
        :resource,
        :code_interface,
        :actions,
        :policies,
        :pub_sub,
        :preparations,
        :changes,
        :validations,
        :multitenancy,
        :attributes,
        :relationships,
        :calculations,
        :aggregates,
        :identities
      ]
    ],
    "Ash.Domain": [section_order: [:resources, :policies, :authorization, :domain, :execution]]
  ]

config :tololo,
  ecto_repos: [Tololo.Repo],
  generators: [timestamp_type: :utc_datetime],
  ash_domains: [Tololo.Support]

# Configures the endpoint
config :tololo, TololoWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: TololoWeb.ErrorHTML, json: TololoWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Tololo.PubSub,
  live_view: [signing_salt: "x8OTxxKq"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :tololo, Tololo.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  tololo: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  tololo: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :kafka_ex,
  brokers: [
    {"localhost", 9092},
    {"localhost", 9093},
    {"localhost", 9094}
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
  disable_default_worker: false,
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
  use_ssl: true,
  # see SSL OPTION DESCRIPTIONS - CLIENT SIDE at http://erlang.org/doc/man/ssl.html
  # for supported options
  ssl_options: [
    # Fix warnings. More at https://github.com/erlang/otp/issues/5352
    verify: :verify_none,
    cacertfile: File.cwd!() <> "/ssl/ca-cert",
    certfile: File.cwd!() <> "/ssl/cert.pem",
    keyfile: File.cwd!() <> "/ssl/key.pem"
  ],

  kafka_version: "0.10.1"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
