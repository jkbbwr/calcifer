defmodule Calcifer.Consumer do
  @moduledoc false

  use Nostrum.Consumer
  require Logger

  def start_link() do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:READY, _ready, _ws_state}) do
    Calcifer.Commands.register_commands()
    Logger.info("Calcifer booted and ready to burn some bacon!")
  end

  def handle_event({:MESSAGE_CREATE, _message, _ws_state}) do
    :noop
  end

  def handle_event({:INTERACTION_CREATE, interaction, _ws_state}) do
    Calcifer.Commands.handle_interaction(interaction)
  end

  def handle_event({:VOICE_STATE_UPDATE, voice_state, _ws_state}) do
    if voice_state.channel_id == nil do
      Calcifer.VoiceCache.disconnected(voice_state.guild_id, voice_state.member.user.id)
    else
      Calcifer.VoiceCache.activity(
        voice_state.guild_id,
        voice_state.member.user.id,
        voice_state.channel_id
      )
    end
  end

  def handle_event({:VOICE_READY, voice_ready, _ws_state}) do
    Calcifer.Jukebox.ready(voice_ready.guild_id)
  end

  def handle_event({:VOICE_SPEAKING_UPDATE, voice_speaking, _ws_state}) do
    Calcifer.Jukebox.update(voice_speaking.speaking)
  end

  def handle_event(_event) do
    :noop
  end
end
