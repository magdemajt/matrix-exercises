defmodule Norms do
  @moduledoc false

  alias Matrix
  alias MatrixOperation

  @iter 1000

  @matrix_size 3

  def norm_m_1(matrix) do
    {rows, cols} = Matrix.size(matrix)

    col1 = Enum.reduce(0..(rows - 1), 0, fn i, acc ->
      acc + Matrix.elem(matrix, i, 0)
    end)
#   sum each column and take max
    Enum.reduce(0..(cols - 1), col1, fn j, acc ->
      Kernel.max(acc, Enum.reduce(0..(rows - 1), 0, fn i, acc ->
        acc + Matrix.elem(matrix, i, j)
      end))
    end)
  end

  def norm_m_inf(matrix) do
    {rows, cols} = Matrix.size(matrix)

    row1 = Enum.reduce(0..(cols - 1), 0, fn j, acc ->
      acc + Matrix.elem(matrix, 0, j)
    end)

    Enum.reduce(0..(rows - 1), row1, fn i, acc ->
      Kernel.max(acc, Enum.reduce(0..(cols - 1), 0, fn j, acc ->
        acc + Matrix.elem(matrix, i, j)
      end))
    end)
  end

  def norm_m_2(matrix) do
    eigenvalues = matrix |>
    MatrixOperation.eigen()
    |> Kernel.elem(0)
    |> Enum.map(fn val -> Kernel.abs(val) end)
    eigenvalues |> Enum.reduce(Enum.at(eigenvalues, 0), fn value, acc -> Kernel.max(acc, value) end)
  end

  def norm_m_p(matrix, p) do
    case p do
      1 -> norm_m_1(matrix)
      2 -> norm_m_2(matrix)
      :inf -> norm_m_inf(matrix)
      _ -> maximal = Enum.reduce(0..@iter, 0, fn _, acc ->
            points = for _ <- 0..(@matrix_size - 2), do: :rand.uniform(2)-1
            last_point = 1 - Enum.reduce(points, 0, fn x, acc -> acc + :math.pow(x, p) end)
            |> Kernel.then(fn x ->
              if x > 0 do
                :math.pow(x, 1/p)
              else
                -1 * :math.pow(Kernel.abs(x), 1/p)
              end
            end)
            points = [points ++ [last_point]]

            Kernel.max(
              acc,
              Matrix.mult(matrix, Matrix.transpose(points))
              |> Matrix.transpose()
              |> Enum.at(0)
              |> Enum.map(fn x -> :math.pow(x, p) end)
              |> Enum.reduce(0, fn x, acc -> acc + x end)
              |> Kernel.then(fn x ->
                if x > 0 do
                  :math.pow(x, 1/p)
                else
                  -1 * :math.pow(Kernel.abs(x), 1/p)
                end
              end))
            end)
           maximal
    end
  end

  def pow(x, p) do

  end

  def svd(matrix) do
    {rows, cols} = Matrix.size(matrix)

    transposed = Matrix.transpose(matrix)

    multiplied = Matrix.mult(matrix, transposed)

    eigen = multiplied |>
    MatrixOperation.eigen()

    sig = eigen |>
    Kernel.elem(0) |>
    Enum.map(fn val ->
      :math.sqrt(val)
    end) |>
    Matrix.diag()

    u = eigen |>
    Kernel.elem(1)|>
    Matrix.transpose()

    multiplied2 = Matrix.mult(transposed, matrix)

    eigen2 = multiplied2 |>
    MatrixOperation.eigen()

    sig2 = eigen2 |>
    Kernel.elem(0) |>
    Enum.map(fn val ->
      :math.sqrt(val)
    end) |>
    Matrix.diag()

    v = eigen2 |>
    Kernel.elem(1)

    {u, sig, v}
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
