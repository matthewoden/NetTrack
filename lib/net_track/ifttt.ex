defmodule NetTrack.IFTTT do
  use Tesla

  @webhook_key Application.get_env(
                 :net_track,
                 :ifttt_webhook_key,
                 System.get_env("IFTTT_WEBHOOK_KEY")
               )

  plug(Tesla.Middleware.BaseUrl, "https://maker.ifttt.com/trigger/")
  plug(Tesla.Middleware.JSON)

  def wifi_arrival(%{hostname: hostname, nickname: nickname}) do
    post("/wifi_arrival/with/key/#{@webhook_key}", %{value1: nickname || hostname})
  end
end
