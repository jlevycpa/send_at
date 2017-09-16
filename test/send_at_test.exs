defmodule SendAtTest do
  use ExUnit.Case
  doctest SendAt

  test "greets the world" do
    assert SendAt.hello() == :world
  end
end
