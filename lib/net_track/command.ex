defmodule NetTrack.Command do
  # ping

  def arp do
    {result, 0} = System.cmd("arp", ["-a"])

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
      |> Enum.map(fn [host, _, mac] -> %{hostname: host, mac_address: mac} end)

    {:ok, results}
  end

  def ping(ip \\ "192.168.1.255") do
    wait_op = if darwin?(), do: "-W", else: "-w"

    {result, 0} = System.cmd("ping", ~w(-c 1 #{wait_op} 5 -s 64 #{ip}))

    if String.starts_with?(result, "PING") do
      :ok
    else
      {:error, result}
    end
  end

  def darwin? do
    {output, 0} = System.cmd("uname", [])
    String.trim_trailing(output) == "Darwin"
  end
end
