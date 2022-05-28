defmodule Calcifer.Commands do
  @moduledoc false
  require Logger

  @commands %{
    "colour" => Calcifer.Commands.Colour,
  }

  @command_names for {name, _} <- @commands, do: name

  def register_commands() do
    guild_id = Application.get_env(:calcifer, :guild)
    commands = for {name, command} <- @commands, do: command.spec(name)
    Nostrum.Api.bulk_overwrite_guild_application_commands(guild_id, commands)
  end

  def handle_interaction(interaction) do
    if interaction.data.name in @command_names do
      @commands[interaction.data.name].handle_interaction(interaction)
    else
      :ok
    end
  end
end
