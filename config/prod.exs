use Mix.Config

config :net_track, NetTrack.Repo,
  database: "nettrack",
  username: System.get_env("NETTRACK_DB_USER"),
  password: System.get_env("NETTRACK_DB_PASSWORD"),
  hostname: System.get_env("NETTRACK_DB_HOST") || "localhost",
  port: System.get_env("NETTRACK_DB_PORT") || 5434

config :net_track,
  subscriptions: [
    {NetTrack.IFTTT, :wifi_arrival}
  ]
