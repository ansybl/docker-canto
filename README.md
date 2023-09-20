# Docker Canto

[![Docker](https://github.com/ansybl/docker-canto/actions/workflows/build.yml/badge.svg)](https://github.com/ansybl/docker-canto/actions/workflows/build.yml)

Canto images for all versions.

# Usage

Pull and use the image directly:

```sh
docker run --env-file .env gcr.io/dfpl-playground/canto
```
Or a specific version:
```sh
docker run --env-file .env gcr.io/dfpl-playground/canto:6.0.0
```

Or build from it:

```dockerfile
FROM gcr.io/dfpl-playground/canto
# any executable within /docker-entrypoint.d/ will get loaded
COPY ./20-extra-init.sh /docker-entrypoint.d/
RUN chmod u+x /docker-entrypoint.d/20-extra-init.sh
RUN apk add vim
```

# Runtime configuration

Most settings from the `~/.cantod/config/*.toml` files can be updated runtime using environment variables.
Each environment variable follow a pattern of:
`<FILENAME>_<SECTION>_<SETTING>` e.g. `CONFIG_STATESYNC_ENABLE`
