defmodule CalciferTest do
  use ExUnit.Case
  doctest Calcifer

  test "greets the world" do
    assert Calcifer.hello() == :world
  end
end
