use Mix.Config

config :net_track, NetTrack.Repo,
  database: "nettrack",
  username: System.get_env("NETTRACK_DB_USER"),
  password: System.get_env("NETTRACK_DB_PASSWORD"),
  hostname: "localhost",
  port: 4432

config :net_track,
  subscriptions: [
    {NetTrack.IFTTT, :wifi_arrival}
  ]
