defmodule Norms do
  @moduledoc false

  alias Matrix
  alias MatrixOperation

  @iter 1000

  @matrix_size 3

  def norm_m_1(matrix) do
    {rows, cols} = Matrix.size(matrix)

#   sum each column and take max
    Enum.reduce(0..(cols - 1), 0, fn j, acc ->
      Kernel.max(acc, Enum.reduce(0..(rows - 1), 0, fn i, acc ->
        acc + Matrix.elem(matrix, i, j)
      end))
    end)
  end

  def norm_m_inf(matrix) do
    {rows, cols} = Matrix.size(matrix)

    Enum.reduce(0..(rows - 1), 0, fn i, acc ->
      Kernel.max(acc, Enum.reduce(0..(cols - 1), 0, fn j, acc ->
        acc + Matrix.elem(matrix, i, j)
      end))
    end)
  end

  def norm_m_2(matrix) do
    {rows, cols} = Matrix.size(matrix)

    transposed = Matrix.transpose(matrix)

    multiplied = Matrix.multiply(transposed, matrix)

    multiplied |>
    MatrixOperation.eigen()
    |> Enum.reduce(0, fn {_, value}, acc -> Kernel.max(acc, value) end)
    |> :math.sqrt()
  end

  def norm_m_p(matrix, p) do
    case p do
      1 -> norm_m_1(matrix)
      2 -> norm_m_2(matrix)
      :inf -> norm_m_inf(matrix)
      _ -> points = Enum.map(0..(@matrix_size - 2), fn _ -> :rand.uniform()  end)
           last_point = 1 - Enum.reduce(points, 0, fn x, acc -> acc + :math.pow(x, p) end) |> :math.pow(1/p)
           points = points ++ [last_point]
           maximal = Enum.reduce(0..@iter, 0, fn _, acc -> Kernel.max(
                                                             acc,
                                                             Matrix.mult(matrix, points)
                                                             |> Enum.map(fn x -> :math.pow(x, p) end)
                                                             |> Enum.reduce(0, fn x, acc -> acc + x end)
                                                             |> :math.pow(1/p))
           end)
           maximal
    end
  end

  def cond_m_1(matrix) do
    norm_m_1(matrix) * norm_m_1(Matrix.inv(matrix))
  end

  def cond_m_2(matrix) do
    norm_m_2(matrix) * norm_m_2(Matrix.inv(matrix))
  end

  def cond_m_p(matrix, p) do
    norm_m_p(matrix, p) * norm_m_p(Matrix.inv(matrix), p)
  end
end
