# Symfony webapp x Blackfire

> :warning: Please note **this is a personal sandbox repo** I'm using to test some configurations that might not be the best ones.
>
> Always refer to https://docs.blackfire.io for battle-tested docs about how to use Blackfire with Symfony :+1:

A playground with Symfony + Blackfire.

It is composed of:

* a symfony app running using php installed on the linux host
* a symfony proxy serving the app with HTTPS
* a dedicated blackfire agent container (listening on port `8311` to avoid conflicts with)
* a command to run the Blackfire Player against the app

## Requirements

* php 8.2 on the host with the blackfire php extension installed
* docker + docker compose
* the `symfony` cli

## Start the app

> :warning: **Please start by configure your php blackfire extension** using the `blackfire/99-blackfire.ini` file.

```shell
# configure app domain and blackfire credentials...
make setup

# tweak your .env.agent.local with your blackfire creds
vim .env.agent.local

# ...then run the stack
make start

# clean everything (proxy domain, containers)
make clean
```

## Run the blackfire player

You can run the default scenario stored in `blackfire/scenarios/simple.bkf` by running

```shell
export BLACKFIRE_ENV="your blackfire environment uuid or name"

# you can also override the scenario being used by defining the BLACKFIRE_SCENARIO env var
make blackfire-player
```

If you want to avoid using `--ssl-no-verify`, you'll also need to mount the symfony certificate in the blackfire player container as a bind mount and run `update-ca-certificates`.
