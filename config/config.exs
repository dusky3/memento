# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# You can control some aspects of the application from here.
#
# Specifically:
#
# - refresh_interval: how often to check for new data. Note that each source
#   uses an indipendent interval.
# - retry_interval: how long to wait before retrying after a failure
#   in fetching new data from a source.
# - enabled_handlers: only handlers listed here are started.

config :memento,
  ecto_repos: [Memento.Repo],
  assets_namespace: "dev",
  twitter_username: "cloud8421",
  github_username: "cloud8421",
  refresh_interval: 60_000 * 5,
  retry_interval: 30_000,
  enabled_handlers: [
    Memento.Capture.Twitter.Handler,
    Memento.Capture.Github.Handler,
    Memento.Capture.Pinboard.Handler,
    Memento.Capture.Instapaper.Handler
  ]

config :memento, Memento.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DATA_DB_USER"),
  password: System.get_env("DATA_DB_PASS"),
  hostname: System.get_env("DATA_DB_HOST"),
  database: "gonano",
  pool_size: 10

config :memento, Memento.RateLimiter,
  max_per_interval: 2,
  reset_interval_in_ms: 10000

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :memento, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:memento, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
import_config "#{Mix.env()}.exs"
