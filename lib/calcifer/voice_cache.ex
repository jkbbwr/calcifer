defmodule Calcifer.VoiceCache do
  @moduledoc false
  alias Nostrum.Cache.UserCache
  alias Nostrum.Cache.GuildCache
  alias Nostrum.Cache.ChannelCache
  use Agent
  require Logger

  def start_link([]) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def activity(guild_id, user_id, channel_id) do
    previous_channel =
      Agent.get_and_update(__MODULE__, fn state ->
        current_channel = get_in(state, [Access.key(guild_id, %{}), user_id])

        {current_channel, put_in(state, [Access.key(guild_id, %{}), user_id], channel_id)}
      end)

    if previous_channel == nil do
      Logger.info(
        "#{UserCache.get!(user_id).username} joined voice channel #{GuildCache.get!(guild_id).name}/#{ChannelCache.get!(channel_id).name}"
      )
    end
  end

  def disconnected(guild_id, user_id) do
    channel_id =
      Agent.get_and_update(__MODULE__, fn state ->
        pop_in(state, [Access.key(guild_id, %{}), user_id])
      end)

    if channel_id == nil do
      Logger.info(
        "#{UserCache.get!(user_id).username} left a voice channel in #{GuildCache.get!(guild_id).name}"
      )
    else
      Logger.info(
        "#{UserCache.get!(user_id).username} left voice channel #{GuildCache.get!(guild_id).name}/#{ChannelCache.get!(channel_id).name}"
      )
    end
  end

  def get(guild_id, user_id) do
    Agent.get(__MODULE__, fn state ->
      get_in(state, [Access.key(guild_id, %{}), Access.key(user_id, nil)])
    end)
  end
end
