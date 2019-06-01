use Mix.Config

config :net_track, NetTrack.Repo,
  database: "nettrack-test",
  username: "nettrack",
  password: "nettrack",
  hostname: "localhost",
  port: 5432,
  pool: Ecto.Adapters.SQL.Sandbox

config :net_track,
  ifttt_webhook_key: System.get_env("IFTTT_WEBHOOK_KEY"),
  subscriptions: []

config :net_track,
  commander: NetTrack.Test.Commander

config :logger, level: :warn
