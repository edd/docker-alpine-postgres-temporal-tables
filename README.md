# PostgreSQL + [temporal_tables](https://github.com/arkhipov/temporal_tables) docker image based on Alpine Linux

[![Docker Automated build](https://img.shields.io/docker/automated/eddhannay/alpine-postgres-temporal-tables.svg?maxAge=2592000)](https://hub.docker.com/r/eddhannay/alpine-postgres-temporal-tables/)

Forked from [kiasaki/docker-alpine-postgres](https://github.com/kiasaki/docker-alpine-postgres).

This repo builds a docker image that accepts the same env vars as the
[official postgres build](https://registry.hub.docker.com/_/postgres/) but
with a much smaller footprint, and the temporal_tables extension installed. It
achieves that by basing itself off the tiny official alpine linux image.

# Build

```bash
$ make build
```

# DockerHub

This image is published on DockerHub as `docker pull eddhannay/alpine-postgres-temporal-tables`.

[Click here to see it's DockerHub homepage](https://hub.docker.com/r/eddhannay/alpine-postgres-temporal-tables/)

# Usage

This image works in the same way the official `postgres` docker image work.

It's documented on DockerHub in it's README: [https://hub.docker.com/_/postgres/](https://hub.docker.com/_/postgres/).

For example, you can start a basic PostgreSQL server, protected by a password,
listening on port 5432 by running the following:

```
$ docker run --name some-postgres -e POSTGRES_PASSWORD=mysecretpassword -d kiasaki/alpine-postgres
```

Next, you can start you app's container while **linking** it to the PostgreSQL
container you just created giving it access to it.

```
$ docker run --name some-app --link some-postgres:postgres -d application-that-uses-postgres
```

Your app will now be able to access `POSTGRES_PORT_5432_TCP_ADDR` and `POSTGRES_PORT_5432_TCP_PORT` environment variables.

# License

MIT. See `LICENSE` file.
