# Docker Canto

[![Docker](https://github.com/ansybl/docker-canto/actions/workflows/build.yml/badge.svg)](https://github.com/ansybl/docker-canto/actions/workflows/build.yml)

Canto images for all versions.

## Usage

Prepare the `.env` file:

```sh
cp .env.example .env
```

Then pull and use the image directly:

```sh
docker run --env-file .env us-docker.pkg.dev/ansybl/public/canto
```

Or a specific version:

```sh
docker run --env-file .env us-docker.pkg.dev/ansybl/public/canto:8.1.3
```

Persisting chain data using volumes:

```sh
docker run --env-file .env --volume $(pwd)/data:/root/.cantod/data us-docker.pkg.dev/ansybl/public/canto
```

Or build from it:

```dockerfile
FROM us-docker.pkg.dev/ansybl/public/canto
# any executable within /docker-entrypoint.d/ will get loaded
COPY ./20-extra-init.sh /docker-entrypoint.d/
RUN chmod u+x /docker-entrypoint.d/20-extra-init.sh
RUN apk add vim
```

## Runtime configuration

Most settings from the `~/.cantod/config/*.toml` files can be updated runtime using environment variables.
Each environment variable follow a pattern of:
`<FILENAME>_<SECTION>_<SETTING>` e.g. `CONFIG_STATESYNC_ENABLE`

For instance to state sync a node:

```
CHAIN_ID=canto_7700-1
CONFIG_STATESYNC_ENABLE=true
```

Or to sync an archive node from scratch:

```
APP_PRUNING=nothing
CHAIN_ID=canto_7700-1
CONFIG_STATESYNC_ENABLE=false
CONFIG_STATESYNC_TRUST_HEIGHT=0
VERSION=1.0.0
```

## Docker compose

We also provide a `docker-compose.yml` file that comes with optional monitoring using Prometheus and Grafana.

```sh
docker compose --profile optional up
```

Grafana dashboard is published on port 3000.
