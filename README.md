# NetTrack

Tracks changes in hosts on the current subnet. Prototype for a "friend doorbell",
dispatching notifications when known devices connect to the network.

## Process

1. pings the broadcast ip for the current subnet:  `ping -c 1 192.168.1.255`
2. checks the arp cache: `arp -a`
3. diffs the results against the last known state, filtering out incomplete/blacklisted devices.

Uses postgres for persistance, which seems like overkill.

TODO:

- add debounce period for disconnects within 5 minutes (longer?)
- refactor
- test

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `net_track` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:net_track, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/net_track](https://hexdocs.pm/net_track).
