defmodule Calcifer.Command do
  @moduledoc false
  alias Nostrum.Struct.Interaction
  @callback spec(name :: String.t()) :: map()
  @callback permissions() :: map()
  @callback handle_interaction(Interaction.t()) :: any()
end
