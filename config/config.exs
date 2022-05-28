import Config

config :logger,
  level: :info,
  metadata: [:shard, :guild, :channel]

config :calcifer,
  guild: 773056915847905281

import_config "#{config_env()}.exs"
