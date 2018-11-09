defmodule ArbitraryTest do
  use ExUnit.Case
  doctest Arbitrary

  test "greets the world" do
    assert Arbitrary.hello() == :world
  end
end
