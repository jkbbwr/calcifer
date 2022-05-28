defmodule Calcifer.Commands.Colour do
  @moduledoc false

  @behaviour Calcifer.Command
  @hex_regex ~r/^([a-fA-F0-9]{6}|[a-fA-F0-9]{3})$/
  alias Calcifer.Respond
  alias Nostrum.Cache.GuildCache
  alias Nostrum.Api
  require Logger

  @impl true
  def spec(name) do
    %{
      name: name,
      description: "Setup a custom hex colour role.",
      options: [
        %{
          type: 3,
          name: "hex",
          description: "Hex code of the colour you want to add",
          required: true
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
    [arg] = interaction.data.options
    colour = arg.value

    with :ok <- validate_colour(colour),
         :ok <- remove_old_colour(interaction),
         :ok <- add_new_colour(interaction, colour) do
      Respond.ephemeral(interaction, "Done!")
    else
      :bad_hex_colour ->
        Respond.ephemeral(
          interaction,
          "Not a valid hex code. It should look something like this `01FF44`"
        )
    end
  end

  defp add_new_colour(interaction, colour) do
    guild = GuildCache.get!(interaction.guild_id)
    {number, _} = Integer.parse(colour, 16)

    # Find or create a role for this hex code.
    role =
      interaction.guild_id
      |> Api.get_guild_roles!()
      |> Enum.find(fn role -> role.name == "##{colour}" end) ||
        Api.create_guild_role!(interaction.guild_id, name: "##{colour}", color: number)

    # Ensure this role is properly positioned
    position = Access.get(guild.roles, 872_237_623_039_651_912).position

    Api.modify_guild_role_positions!(interaction.guild_id, [
      %{id: role.id, position: position - 1}
    ])

    Logger.info("Adding colour role #{role.name} to #{interaction.user.username}")
    {:ok} = Api.add_guild_member_role(
      interaction.guild_id,
      interaction.member.user.id,
      role.id
    )

    :ok
  end

  defp remove_old_colour(interaction) do
    guild = GuildCache.get!(interaction.guild_id)

    role =
      Enum.find(interaction.member.roles, fn role ->
        role = Access.get(guild.roles, role)
        String.starts_with?(role.name, "#")
      end)

    if role != nil do
      Logger.info("Removing colour role #{Access.get(guild.roles, role).name} from #{interaction.user.username}")
      Api.remove_guild_member_role(interaction.guild_id, interaction.member.user.id, role)
    end

    :ok
  end

  defp validate_colour(colour) do
    if Regex.match?(@hex_regex, colour) do
      :ok
    else
      :bad_hex_colour
    end
  end
end
