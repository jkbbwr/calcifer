FROM elixir:alpine as builder

RUN apk update && apk add git

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV="prod"

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/prod.exs config/
RUN mix deps.compile

COPY lib lib

RUN mix compile

COPY config/runtime.exs config/

RUN mix release

FROM elixir:alpine

WORKDIR "/app"
RUN chown nobody /app

RUN apk update && apk add youtube-dl

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/prod/rel ./

USER nobody

RUN set -eux; \
  ln -nfs /app/$(basename *)/bin/$(basename *) /app/entry

CMD /app/entry start
