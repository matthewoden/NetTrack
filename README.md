# NetTrack

Tracks changes in hosts on the current subnet. Prototype for a "friend doorbell",
dispatching notifications when known devices connect to the network.

Uses postgres for persistance, which seems like overkill.

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
