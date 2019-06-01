# NetTrack

Prototype for a "friend doorbell", dispatching push notifications when known devices
connect to the local network.

## Process
NetTrack is a thin wrapper over a couple shell commands.

1. pings the broadcast ip for the current subnet: `ping -c 1 192.168.1.255`
2. checks the arp cache: `arp -a`
3. Diffs the arp table results against the last check of the arp table, filtering out incomplete/blacklisted devices.
4. Sends notifications for any new arrivals.

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

### Database

NetTrack uses Postgres for blacklist/activity persistance, and expects the
database and user to exist on the postgres instance prior to deployment.

### IFTTT (Push notifications)

NetTrack uses ifttt.com for push notifications. You'll need an IFTTT account,
and enable the following services:

- [webhook](https://ifttt.com/maker_webhooks)
- [IFTTT app notifications](https://ifttt.com/services/if_notifications)

Make note of your webhook key, as we'll use that later.

### Environment

The following environment variables can be used to configure your NetTrack instance

#### required:

```bash
NETTRACK_DB_USER #your postgres user
NETTRACK_DB_PASSWORD #your postgres password
NETTRACK_DB_DATABASE #your postgres database
NETTRACK_DB_HOST #your postgres host
IFTTT_WEBHOOK_KEY #your IFTTT webhook token
```

#### optional:

```bash
NETTRACK_DB_PORT #your postgres port, defaults to 5432
```
---

TODO:

- add debounce period for disconnects within a set period
- add UI layer for adding nicknames, blacklists
- add option to use sqlite for persistance
- add option to not send notifications if certain devices are absent
- add option to take a list of IFTTT endpoints for notifications
- add API layer to enable hooks into homebridge
