defmodule NetTrack.Test.Commander do
  def cmd("arp", ["-a"]) do
    output = ~S"""
    ? (192.168.1.1) at ab:cd:ef:gh:ij:kl on en0 ifscope [ethernet]
    testhost.local (192.168.1.2) at cd:ef:gh:ij:kl:ab on en0 ifscope [ethernet]
    broadcasthost (255.255.255.255) at ff:ff:ff:ff:ff:ff on en0 ifscope [ethernet]
    """

    {output, 0}
  end

  def cmd("ping", ["-c", "1", "-W", "5", "-s", "64", "192.168.1.255"]) do
    output = ~S"""
    PING 192.168.1.255 (192.168.1.255): 56 data bytes
    --- 192.168.1.255 ping statistics ---
    1 packets transmitted, 1 packets received, +0 duplicates, 0.0% packet loss
    round-trip min/avg/max/stddev = 0.064/49.014/266.388/90.640 ms
    """

    {output, 0}
  end

  def cmd("ping", _) do
    output = ~S"""
    ping: invalid count of packets to transmit:
    """

    {output, 0}
  end

  def cmd("uname", []) do
    output = ~S"""
    Darwin
    """

    {output, 0}
  end
end
