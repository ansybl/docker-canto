# Docker Canto

[![Docker](https://github.com/ansybl/docker-canto/actions/workflows/build.yml/badge.svg)](https://github.com/ansybl/docker-canto/actions/workflows/build.yml)

Canto images for all versions.

# Usage

Pull and use the image directly:

```sh
docker run gcr.io/dfpl-playground/canto:5.0.2
```

Or build from it:

```dockerfile
FROM gcr.io/dfpl-playground/canto:5.0.2
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod u+x /usr/local/bin/entrypoint.sh
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
```
