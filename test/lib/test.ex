defmodule Test do
  @moduledoc """
  Documentation for `Test`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Test.hello()
      :world

  """
  def hello do
    :world
  end

  def multi(m1, m2, size) do
      Arrays.new(for i <- 0..size-1, do:
        Arrays.new(for j <- 0..size-1, do:
          Enum.reduce(0..size-1, 0, fn k, acc -> m1[i][k] * m2[k][j] + acc end)))
  end
end
