FROM hexpm/elixir:1.19.6-erlang-28.5.0.8-alpine-3.24.2 AS build

RUN mkdir /app
WORKDIR /app

RUN mix do local.hex --force, local.rebar --force

ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
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

# must use the same alpine version as the build image
FROM alpine:3.24.2 AS app

# install runtime dependencies
RUN apk add --no-cache bash libstdc++ openssl ncurses-libs ca-certificates

ENV MIX_ENV=prod

# prepare app directory
RUN mkdir /app
WORKDIR /app


# copy release to app container
COPY --from=build /app/_build/prod/rel/bonsaika .
RUN chown -R nobody: /app
USER nobody

ENV HOME=/app
ENTRYPOINT ["/app/bin/bonsaika", "start"]
