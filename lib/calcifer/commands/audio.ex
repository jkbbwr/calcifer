defmodule Calcifer.Commands.Audio do
  @moduledoc false

  @behaviour Calcifer.Command
  alias Calcifer.Respond
  alias Nostrum.Voice
  alias Calcifer.VoiceCache
  alias Calcifer.Jukebox

  require Logger

  @impl true
  def spec(name) do
    %{
      name: name,
      description: "Play audio from a youtube video",
      options: [
        %{
          name: "disconnect",
          description: "Banish calcifer from the voice channel.",
          type: 1
        },
        %{
          name: "join",
          description: "Have calcifer join the voice channel but not play anything.",
          type: 1
        },
        %{
          name: "play",
          description: "Start playing this audio immediately.",
          type: 1,
          options: [
            %{
              name: "url",
              description: "The URL to start playing.",
              type: 3,
              required: true
            }
          ]
        },
        %{
          name: "queue",
          description: "Add this audio to the end of the queue.",
          type: 1,
          options: [
            %{
              name: "url",
              description: "The URL to queue at the end.",
              type: 3,
              required: true
            }
          ]
        }
      ]
    }
  end

  @impl true
  def permissions() do
    %{}
  end

  @impl true
  def handle_interaction(interaction) do
    [option] = interaction.data.options

    case option.name do
      "disconnect" -> disconnect(interaction)
      "join" -> join(interaction)
      "play" -> play(interaction)
    end
  end

  defp disconnect(interaction) do
    Logger.info("Disconnecting from voice channel.")
    Voice.leave_channel(interaction.guild_id)
    Respond.ephemeral(interaction, "Done.")
  end

  defp join(interaction) do
    channel_id = VoiceCache.get(interaction.guild_id, interaction.member.user.id)

    if channel_id == nil do
      Respond.ephemeral(
        interaction,
        "Sorry, I lost track of what voice channel you are in, can you rejoin the channel then run this command again."
      )
    else
      Logger.info("Joining voice channel.")
      Voice.join_channel(interaction.guild_id, channel_id, false, true)
    end

    Respond.ephemeral(interaction, "Done.")
  end

  defp play(interaction) do
    [url] = get_in(interaction, [:data, :ioptions, Access.at(0), :options, Access.at(0), :value])
    Jukebox.play(url)
    Respond.ephemeral(interaction, "Done.")
  end
end
