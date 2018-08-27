defmodule TransmitterTest do
  use ExUnit.Case
  doctest Transmitter

  test "greets the world" do
    assert Transmitter.hello() == :world
  end
end
