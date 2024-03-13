defmodule Test do
  def add(a, b, size) do
    Arrays.new(for i <- 0..size-1, do:
        Arrays.new(for j <- 0..size-1, do: a[i][j] + b[i][j]))
  end

  def multi(a, b, size) do
      Arrays.new(for i <- 0..size-1, do:
        Arrays.new(for j <- 0..size-1, do:
          Enum.reduce(0..size-1, 0, fn k, acc ->a[i][k] * b[k][j] + acc end)))
  end

# make multi but with enum


  def strassen(a, b, exp, l) do
    a11 = Arrays.new(for i <- 0..Math.pow(2, l-1)-1, do:
            Arrays.new(for j <- 0..Math.pow(2, l-1)-1, do: a[i][j]))

  end
end
