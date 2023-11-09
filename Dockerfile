FROM elixir:1.15-alpine as build

RUN mkdir /app
WORKDIR /app

RUN mix do local.hex --force, local.rebar --force

ENV MIX_ENV=prod


# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mix deps.compile


# build project
COPY lib lib
RUN mix compile

# build release
# at this point we should copy the rel directory but
# we are not using it so we can omit it
# COPY rel rel
RUN mix release

FROM alpine:3.18 AS app

# install runtime dependencies
RUN apk add --update bash

ENV MIX_ENV=prod

# prepare app directory
RUN mkdir /app
WORKDIR /app


# copy release to app container
COPY --from=build /app/_build/prod/rel/bonsaika .
RUN chown -R nobody: /app
USER nobody

ENV HOME=/app
ENTRYPOINT ["/app/bonsaika/bin/bonsaika", "start"]
