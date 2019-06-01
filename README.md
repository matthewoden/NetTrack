# NetTrack

Prototype for a "friend doorbell", dispatching push notifications when known devices
connect to the local network.

## Process

1. pings the broadcast ip for the current subnet: `ping -c 1 192.168.1.255`
2. checks the arp cache: `arp -a`
3. diffs the results against the last known state, filtering out incomplete/blacklisted devices.

## Running NetTrack

### ...with docker:

NetTrack is available in docker. Access to the host network is required.

```
docker pull matthewoden/net_track:latest
```

See the provided [./docker-compose.yml](./docker-compose.yml) file
for an example docker configuration.

### ...as an elixir release:

The elixir release can be run without docker, if desired.

```bash
MIX_ENV=prod mix release

# using the default release location:
_build/prod/rel/net_track/bin/net_track migrate
_build/prod/rel/net_track/bin/net_track foreground
```

## Configuration

NetTrack uses Postgres for blacklist/activity persistance, and expects the
database and user exist prior to start.

### IFTTT (Push notifications)

NetTrack uses ifttt.com for push notifications. You'll need an IFTTT account,
and enable the following services:

- [webhook](https://ifttt.com/maker_webhooks)
- [IFTTT app notifications](https://ifttt.com/services/if_notifications)

Make note of your webhook key, to use below.

### Environment

The following environment variables can be used to configure your NetTrack instance

#### required:

```bash
NETTRACK_DB_USER #your postgres user
NETTRACK_DB_PASSWORD #your postgres password
NETTRACK_DB_DATABASE #your postgres database
IFTTT_WEBHOOK_KEY #your IFTTT webhook token
NETTRACK_DB_HOST #your postgres host
```

#### Optional

```bash
NETTRACK_DB_PORT #your postgres port, defaults to 5432
```

TODO:

- add debounce period for disconnects within a set period
- add UI layer for adding nicknames, blacklists
- add option to use sqlite for persistance?
