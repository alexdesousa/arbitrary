defmodule Arbitrary.Gen do
  use Witchcraft

  import Algae

  alias __MODULE__, as: Gen
  alias Arbitrary.Control

  defdata do
    gen :: (integer() -> any())
  end

  def choose(range) do
    new(fn _ -> Enum.random(range) end)
  end

  def oneof([]) do
    raise "oneof/1 used with an empty list"
  end

  def oneof(gs) do
    monad %Gen{} do
      n <- choose(0..(length(gs) - 1))
      Enum.at(gs, n)
    end
  end

  def frequency([]) do
    raise "frequency/1 used with an empty list"
  end

  def frequency(fs) when is_list(fs) do
    total =
      fs
      |> Stream.map(&elem(&1, 0))
      |> Enum.sum()

    monad %Gen{} do
      n <- choose(1..total)
      pick(n, fs)
    end
  end

  defp pick(n, [{k, x} | xs]) do
    if n <= k, do: x, else: pick(n - k, xs)
  end

  defp pick(n, []) do
    raise "pick/2 used with empty list"
  end

  def elements([]) do
    raise "elements/1 used with empty list"
  end

  def elements(xs) do
    monad %Gen{} do
      n <- choose(0..(length(xs) - 1))
      return(Enum.at(xs, n))
    end
  end

  def sublist_of(xs) do
    %Gen{}
    |> Control.filter(xs, fn _ -> choose([false, true]) end)
  end

  def generate(%{gen: f}) do
    f.(30)
  end
end

import TypeClass
use Witchcraft

alias Arbitrary.Gen

definst Witchcraft.Functor, for: Gen do
  @force_type_instance true

  # fmap
  # map :: Gen (Int -> a) -> (a -> b) -> Gen (Int -> b)
  def map(%Gen{gen: g}, f) do
    Gen.new(fn x ->
      f.(g.(x))
    end)
  end
end

definst Witchcraft.Apply, for: Gen do
  @force_type_instance true

  # convey :: Gen (Int -> (a -> b)) -> Gen (Int -> a) -> Gen (Int -> b)
  def convey(%Gen{gen: f}, %Gen{gen: g}) do
    Gen.new(fn x ->
      (fn h -> map(g, h) end).(f.(x))
    end)
  end
end

definst Witchcraft.Applicative, for: Gen do
  @force_type_instance true

  # return
  # of :: Functor a => a -> Gen (Int -> a)
  def of(_, data) do
    Gen.new(fn _ -> data end)
  end
end

definst Witchcraft.Chain, for: Gen do
  @force_type_instance true

  # bind
  # chain :: Gen (Int -> a) -> (a -> Gen (Int -> b)) -> Gen (Int -> b)
  def chain(%Gen{gen: f}, g) do
    Gen.new(fn x ->
      %Gen{gen: h} = g.(f.(x))
      h.(x)
    end)
  end
end

definst Witchcraft.Monad, for: Gen do
  @force_type_instance true
end
