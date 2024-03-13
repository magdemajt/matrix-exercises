defmodule Test do
  def print(m, size) do
    res = ""
    for i <- 0..size-1, do: for j <- 0..size-1, do: res <> " #{m[i][j]}"
  end

  def add(a, b, size) do
    Arrays.new(for i <- 0..size-1, do:
        Arrays.new(for j <- 0..size-1, do: a[i][j] + b[i][j]))
  end

  def sub(a, b, size) do
    Arrays.new(for i <- 0..size-1, do:
        Arrays.new(for j <- 0..size-1, do: a[i][j] - b[i][j]))
  end

  def multi(a, b, size) do
    Arrays.new(for i <- 0..size-1, do:
      Arrays.new(for j <- 0..size-1, do:
        Enum.reduce(0..size-1, 0, fn k, acc ->a[i][k] * b[k][j] + acc end)))
  end

  def strassen(a, b, exp, l) do
    size = Math.pow(2, exp-1)
    if exp <= l or exp <= 1 do
      multi(a, b, size)
    else
      a11 = Arrays.new(for i <- 0..size-1, do:
              Arrays.new(for j <- 0..size-1, do: a[i][j]))
      a21 = Arrays.new(for i <- size..2*size-1, do:
              Arrays.new(for j <- 0..size-1, do: a[i][j]))
      a12 = Arrays.new(for i <- 0..size-1, do:
              Arrays.new(for j <- size..2*size-1, do: a[i][j]))
      a22 = Arrays.new(for i <- size..2*size-1, do:
              Arrays.new(for j <- size..2*size-1, do: a[i][j]))

      b11 = Arrays.new(for i <- 0..size-1, do:
              Arrays.new(for j <- 0..size-1, do: b[i][j]))
      b21 = Arrays.new(for i <- size..2*size-1, do:
              Arrays.new(for j <- 0..size-1, do: b[i][j]))
      b12 = Arrays.new(for i <- 0..size-1, do:
              Arrays.new(for j <- size..2*size-1, do: b[i][j]))
      b22 = Arrays.new(for i <- size..2*size-1, do:
              Arrays.new(for j <- size..2*size-1, do: b[i][j]))

      p1 = strassen(add(a11, a22, size), add(b11, b22, size), exp-1, l)

      p2 = strassen(add(a21, a22, size), b11, exp-1, l)
      p3 = strassen(a11, sub(b12, b22, size), exp-1, l)
      p4 = strassen(a22, sub(b21, b11, size), exp-1, l)
      p5 = strassen(add(a11, a12, size), b22, exp-1, l)

      p6 = strassen(sub(a21, a11, size), add(b11, b12, size), exp-1, l)
      p7 = strassen(sub(a12, a22, size), add(b21, b22, size), exp-1, l)

      IO.puts(size)
      Arrays.new(for i <- 0..2*size-1, do:
        Arrays.new(for j <- 0..2*size-1, do: {
          IO.puts("#{i}, #{j}"),
          if i < size do
            if j < size do
              p1[i][j]+p4[i][j]-p5[i][j]+p7[i][j]
            else
              p3[i][j-size] + p5[i][j-size]
            end
          else
            if j < size do
              p2[i-size][j] + p4[i-size][j]
            else
              p1[i-size][j-size] - p2[i-size][j-size] + p3[i-size][j-size] + p6[i-size][j-size]
            end
          end
        }))
      end
  end
end
