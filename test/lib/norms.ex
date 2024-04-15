defmodule MatrixNorm do
  @size = 3

  def norm1(matrix) do
    cols_sum = for _ <- 0..size-1, do: 0
    res = Enum.reduce(0..size-1, cols_sum, fn row, acc ->
      for cell <- 0..size-1, do: Enum.at(cols_sum, cell) = Enum.at(matrix, row) |> Enum.at(cell)
    end)
    |> Enum.max(cols_sum)
    res
  end
end
