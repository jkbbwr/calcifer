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

  def handle_event(_event) do
    :noop
  end
end
