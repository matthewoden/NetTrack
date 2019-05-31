use Mix.Config

config :net_track, NetTrack.Repo,
  database: "nettrack-test",
  username: System.get_env("NETTRACK_DB_USER"),
  password: System.get_env("NETTRACK_DB_PASSWORD"),
  hostname: "localhost",
  port: 5432,
  pool: Ecto.Adapters.SQL.Sandbox

config :net_track,
  commander: NetTrack.Test.Commander,
  ifttt_webhook_key: System.get_env("IFTTT_WEBHOOK_KEY"),
  subscriptions: []

config :logger, level: :warn
