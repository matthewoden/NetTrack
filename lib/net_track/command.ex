defmodule NetTrack.Command do
  @commander Application.get_env(:net_track, :commander, System)

  @spec arp :: {:ok, [%{hostname: String.t(), mac_address: String.t()}]} | {:error, :invalid_arp}
  def arp do
    with {result, 0} <- command("arp", ["-a"]) do
      results =
        String.split(result, "\n", trim: true)
        |> Stream.reject(&String.starts_with?(&1, "?"))
        |> Stream.map(fn line ->
          line
          |> String.replace(~r/\(|\) at/, "")
          |> String.split(" ", trim: true)
          |> Enum.take(3)
        end)
        |> Stream.reject(fn x -> length(x) !== 3 end)
        |> Stream.reject(fn [host | _] -> host == "broadcasthost" end)
        |> Enum.map(fn [host, _, mac] -> %{hostname: host, mac_address: normalize_mac(mac)} end)

      {:ok, results}
    else
      _ ->
        {:error, :invalid_arp}
    end
  end

  def normalize_mac(mac_address) do
    String.split(mac_address, ":")
    |> Enum.map(fn segment -> String.pad_leading(segment, 2, "0") end)
    |> Enum.join(":")
  end

  @spec ping(broadcast_ip :: String.t()) :: :ok | {:error, :invalid_ping}
  def ping(ip \\ "192.168.1.255") do
    wait_op = if darwin?(), do: "-W", else: "-w"
    ping_args = ~w(-c 1 #{wait_op} 5 -s 64 #{ip})

    with {result, 0} <- command("ping", ping_args),
         true <- String.starts_with?(result, "PING") do
      :ok
    else
      _ ->
        {:error, :invalid_ping}
    end
  end

  @spec darwin? :: boolean
  def darwin? do
    with {output, 0} <- command("uname", []) do
      String.trim_trailing(output) == "Darwin"
    else
      _ ->
        false
    end
  end

  defp command(bin, arglist) do
    @commander.cmd(bin, arglist)
  end
end
