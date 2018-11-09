defmodule Arbitrary.Control do
  use Witchcraft

  def map(m, [], _) do
    monad m do
      return([])
    end
  end

  def map(m, [x | xs], f) do
    monad m do
      y <- f.(x)
      ys <- map(m, xs, f)
      return([y | ys])
    end
  end

  def filter(m, [], _) do
    monad m do
      return([])
    end
  end

  def filter(m, [x | xs], p) do
    monad m do
      b <- p.(x)
      ys <- filter(m, xs, p)
      return(if b, do: [x | ys], else: ys)
    end
  end

  def foldl(m, [], acc, _op) do
    monad m do
      return(acc)
    end
  end

  def foldl(m, [x | xs], acc, op) do
    monad m do
      new_acc <- op.(x, acc)
      foldl(m, xs, new_acc, op)
    end
  end
end
