use Mix.Config

config :net_track,
  ifttt_webhook_key: System.get_env("IFTTT_WEBHOOK_KEY")

config :net_track,
  ecto_repos: [NetTrack.Repo]

import_config "#{Mix.env()}.exs"
