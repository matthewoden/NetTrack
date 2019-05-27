# NetTrack

Tracks changes in hosts on the current subnet. Prototype for a "friend doorbell",
dispatching notifications when known devices connect to the network.

## Process

Scrapes the subnet off the broadcast ip, `ping -c 1 192.168.1.255`, then checking
the arp cache (`arp -a`), and processing the results.

Uses postgres for persistance, which seems like overkill.

TODO:

- add debounce period for disconnects within 5 minutes.
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
