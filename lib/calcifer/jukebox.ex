defmodule Calcifer.Jukebox do
  @moduledoc false
  use GenServer
  alias Nostrum.Voice
  require Logger

  def start_link([]) do
    GenServer.start_link(__MODULE__, %{queue: [], ready: false, playing: false, guild_id: nil},
      name: __MODULE__
    )
  end

  def init(state) do
    {:ok, state}
  end

  def play(url) do
    GenServer.call(__MODULE__, {:play, url})
  end

  def queue(url) do
    GenServer.call(__MODULE__, {:queue, url})
  end

  def stop() do
    GenServer.call(__MODULE__, :stop)
  end

  def ready(guild_id) do
    GenServer.call(__MODULE__, {:ready, guild_id})
  end

  def disconnected() do
    GenServer.call(__MODULE__, :disconnected)
  end

  def update(speaking) do
    GenServer.call(__MODULE__, {:update, speaking})
  end

  def skip() do
    GenServer.call(__MODULE__, :skip)
  end

  def pause() do
    GenServer.call(__MODULE__, :pause)
  end

  # We got asked to play something and we are ready
  def handle_call({:play, url}, _from, %{ready: true} = state) do
    Voice.play(state.guild_id, url, :ytdl)
    {:reply, :ok, state}
  end

  def handle_call({:play, url}, _from, %{ready: false} = state) do
    {:reply, :ok, update_in(state, [:queue], &[url | &1])}
  end

  def handle_call({:queue, url}, _from, state) do
    {:reply, :ok, update_in(state, [:queue], &(&1 ++ [url]))}
  end

  def handle_call(:pause, _from, state) do
    Voice.pause(state.guild_id)
    {:reply, :ok, put_in(state, [:playing], false)}
  end

  def handle_call(:resume, _from, state) do
    Voice.resume(state.guild_id)
    {:reply, :ok, state}
  end

  def handle_call({:ready, guild_id}, _from, state) do
    Logger.info("Jukebox is now ready.")

    state =
      state
      |> put_in([:guild_id], guild_id)
      |> put_in([:ready], true)

    {:reply, :ok, state}
  end

  # Discord has informed us we are speaking
  def handle_call({:update, true}, _from, state) do
    {:reply, :ok, state}
  end

  # We are not in a playing state. Discord said we stopped speaking
  def handle_call({:update, false}, _from, %{playing: false} = state) do
    {:reply, :ok, state}
  end

  # We are in a playing state. Discord said we stopped speaking
  def handle_call({:update, false}, _from, %{playing: true} = state) do
    {:reply, :ok, state}
  end

  def handle_call(:skip, _from, state) do
    {:reply, :ok, state}
  end

  def handle_call(:disconnected, _from, _state) do
    {:reply, :ok, %{queue: [], ready: false, playing: false, guild_id: nil}}
  end
end
