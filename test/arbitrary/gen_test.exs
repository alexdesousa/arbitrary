defmodule Arbitrary.GenTest do
  use ExUnit.Case, async: true

  alias Arbitrary.Gen

  describe "choose/1" do
    test "generates a function" do
      %Gen{gen: f} = Gen.choose(1..10)
      assert is_function(f)
    end

    test "chooses one value of a range" do
      a = 1
      b = 10
      value =
        a..b
        |> Gen.choose()
        |> Gen.generate()
      assert a <= value and value <= b
    end
  end

  describe "elements/1" do
    test "generates a function" do
      values = Enum.to_list(1..10)
      %Gen{gen: f} = Gen.elements(values)
      assert is_function(f)
    end

    test "gets a value from a list" do
      a = 1
      b = 10
      value =
        a..b
        |> Enum.to_list()
        |> Gen.elements()
        |> Gen.generate()
      assert a <= value and value <= b
    end
  end

  describe "sublist_of/1" do
    test "generates a function" do
      %Gen{gen: f} = Gen.sublist_of([1,2,3])
      assert is_function(f)
    end

    test "gets a subset from a list with values" do
      set = [1,2,3,4]
      subset =
        set
        |> Gen.sublist_of()
        |> Gen.generate()
      assert for i <- subset, do: Enum.member?(set, i)
      assert length(subset) <= length(set)
    end
  end

  describe "oneof/1" do
    test "generates a function" do
      %Gen{gen: f} = Gen.oneof([Gen.choose(1..10)])
      assert is_function(f)
    end

    test "gets one of the generators" do
      a = 1
      b = 10
      generators = [
        Gen.choose(a..b),
        Gen.elements([21, 42])
      ]

      value =
        generators
        |> Gen.oneof()
        |> Gen.generate()

      assert (a <= value and value <= b) or value == 21 or value == 42
    end
  end

  describe "frequency/1" do
    test "generates a function" do
      %Gen{gen: f} = Gen.frequency([{1, Gen.choose(1..10)}])
      assert is_function(f)
    end

    test "gets one of the generator according to the frequency" do
      a = 1
      b = 10
      generators = [
        {0, Gen.choose(a..b)},
        {1, Gen.elements([21, 42])}
      ]

      value =
        generators
        |> Gen.frequency()
        |> Gen.generate()

      assert (a != value or value != b) and (value == 21 or value == 42)
    end
  end
end
