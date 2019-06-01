defmodule NetTrack.IFTTT do
  use Tesla
  require Logger

  plug(Tesla.Middleware.BaseUrl, "https://maker.ifttt.com/trigger/")
  plug(Tesla.Middleware.JSON)
  plug(Tesla.Middleware.Logger)

  def wifi_arrival(%{hostname: hostname, nickname: nickname}) do
    Logger.debug("Firing WIFI arrival event for #{hostname}")

    post("/wifi_arrival/with/key/#{System.get_env("IFTTT_WEBHOOK_KEY")}", %{
      value1: nickname || hostname
    })
  end
end
