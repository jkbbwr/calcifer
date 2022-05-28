defmodule Calcifer.Respond do
  @moduledoc false

  use Bitwise
  alias Nostrum.Api

  def ephemeral(interaction, message) do
    payload = %{
      type: 4,
      data: %{
        content: message,
        flags: 1 <<< 6
      }
    }

    Api.create_interaction_response!(interaction, payload)
  end
end
