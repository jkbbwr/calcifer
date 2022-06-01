import Config

config :logger,
  level: :info,
  metadata: [:shard, :guild, :channel]

config :calcifer,
  guild: 773_056_915_847_905_281


import_config "#{config_env()}.exs"
