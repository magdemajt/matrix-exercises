defmodule GaussMatrix do
  @matrix_size (10 + 2)

  @spec gauss_elimination(matrix :: Matrix.matrix()) :: Matrix.matrix()
  def gauss_elimination(matrix) do
    {rows, cols} = Matrix.size(matrix)

    Enum.reduce(0..(rows - 2), matrix, fn i, acc ->
      Enum.reduce((i + 1)..(rows - 1), acc, fn j, acc ->
        factor = Matrix.elem(acc, j, i) / Matrix.elem(acc, i, i)
        update_row(acc, j, i, factor)
      end)
    end)
  end

  def update_row(matrix, row, col, factor) do
    {rows, cols} = Matrix.size(matrix)

    matrix = Enum.reduce(0..(cols - 1), matrix, fn i, acc ->
      old_val = Matrix.elem(acc, row, i)
      subtract_val = Matrix.elem(acc, col, i) * factor
      new_val = old_val - subtract_val
      Matrix.set(acc, row, i, new_val)
    end)

    matrix
  end

  def gauss_elimination_with_pivot(matrix) do
    {rows, cols} = Matrix.size(matrix)

    matrix = Enum.reduce(0..(rows - 2), matrix, fn i, acc ->
      acc = pivot(acc, i)
      Enum.reduce((i + 1)..(rows - 1), acc, fn j, acc ->
        factor = Matrix.elem(acc, j, i) / Matrix.elem(acc, i, i)
        update_row(acc, j, i, factor)
      end)
    end)
    matrix
  end

  def pivot(matrix, col) do
    {rows, cols} = Matrix.size(matrix)

    max_row_index = 0
    max_row_value = 10000

    {max_row_index, max_row_value} = Enum.reduce(col..(rows - 1), {max_row_index, max_row_value}, fn i, {max_row_index, max_row_value} ->
      if abs(Matrix.elem(matrix, i, col)) > max_row_value do
        {i, abs(Matrix.elem(matrix, i, col))}
      else
        {max_row_index, max_row_value}
      end
    end)

    if max_row_index != col do
      matrix = Enum.reduce(0..(cols - 1), matrix, fn i, matrix ->
        temp = Matrix.elem(matrix, col, i)
        matrix = Matrix.set(matrix, col, i, Matrix.elem(matrix, max_row_index, i))
        matrix = Matrix.set(matrix, max_row_index, i, temp)
        matrix
      end)
      matrix
    end
    matrix
  end

  def random_matrix do
    matrix = Matrix.new(@matrix_size, @matrix_size, 1)

    matrix = for i <- 0..(@matrix_size - 1), reduce: matrix do
      matrix -> for j <- 0..(@matrix_size - 1), reduce: matrix do
        matrix -> Matrix.set(matrix, i, j, :rand.uniform(100))
      end
    end
    matrix
  end

  def result_vector do
    vector = Matrix.new(@matrix_size, 1, 1)

    vector = for i <- 0..(@matrix_size - 1), reduce: vector do
      vector -> Matrix.set(vector, i, 0, :rand.uniform(100))
    end
    vector
  end

  def lu_decomposition(matrix) do
    {rows, _} = Matrix.size(matrix)
    {l, u} = {Matrix.ident(rows), matrix}

    Enum.reduce(0..(rows - 1), {l, u}, fn i, {l, u} ->
      divisor = Matrix.elem(u, i, i)
      if divisor != 0 do
        Enum.reduce(i..(rows - 1), {l, u}, fn j, {l, u} ->
          factor = Matrix.elem(u, j, i) / divisor
          l = update_matrix(l, j, i, factor)
          u = update_matrix(u, j, i, factor)
          {l, u}
        end)
      else
        {l, u}
      end
    end)
  end

  def lu_decomposition_with_pivot(matrix) do
    {rows, _} = Matrix.size(matrix)
    {l, u, p} = {Matrix.ident(rows), matrix, Matrix.ident(rows)}

    Enum.reduce(0..(rows - 1), {l, u, p}, fn i, {l, u, p} ->
      {l, u, p} = pivot(l, u, p, i)
      Enum.reduce(i..(rows - 1), {l, u, p}, fn j, {l, u, p} ->
        divisor = Matrix.elem(u, i, i)
        if divisor != 0 do
          factor = Matrix.elem(u, j, i) / divisor
          l = update_matrix(l, j, i, factor)
          u = update_matrix(u, j, i, factor)
        end
        {l, u, p}
      end)
    end)
  end

  defp pivot(l, u, p, col) do
    {rows, _} = Matrix.size(u)
    max_row_index = 0
    max_row_value = 10000

    {max_row_index, max_row_value} = Enum.reduce(col..(rows - 1), {max_row_index, max_row_value}, fn i, {max_row_index, max_row_value} ->
      if abs(Matrix.elem(u, i, col)) > max_row_value do
        {i, abs(Matrix.elem(u, i, col))}
      else
        {max_row_index, max_row_value}
      end
    end)

    if max_row_index != col do
      u = Enum.reduce(0..(rows - 1), u, fn i, u ->
        temp = Matrix.elem(u, col, i)
        u = Matrix.set(u, col, i, Matrix.elem(u, max_row_index, i))
        u = Matrix.set(u, max_row_index, i, temp)
      end)

      l = Enum.reduce(0..(rows - 1), l, fn i, l ->
        temp = Matrix.elem(l, col, i)
        l = Matrix.set(l, col, i, Matrix.elem(l, max_row_index, i))
        l = Matrix.set(l, max_row_index, i, temp)
      end)

      p = Enum.reduce(0..(rows - 1), p, fn i, p ->
        temp = Matrix.elem(p, col, i)
        p = Matrix.set(p, col, i, Matrix.elem(p, max_row_index, i))
        p = Matrix.set(p, max_row_index, i, temp)
      end)

      {l, u, p}
    end

    {l, u, p}
  end

  def update_matrix(matrix, row, col, factor) do
    {rows, cols} = Matrix.size(matrix)

    Enum.reduce(0..(cols - 1), matrix, fn i, matrix ->
      old_val = Matrix.elem(matrix, row, i)
      subtract_val = Matrix.elem(matrix, col, i) * factor
      new_val = old_val - subtract_val
      Matrix.set(matrix, row, i, new_val)
    end)
  end

  def solve_system_lu(a, b, :unstable) do
    {l, u, p} = lu_decomposition_with_pivot(a)
    y = forward_substitution(l, Matrix.mult(p, b))
    x = backward_substitution(u, y)
    x
  end

  def solve_system_lu(a, b, :stable) do
    {l, u} = lu_decomposition(a)
    y = forward_substitution(l, b)
    x = backward_substitution(u, y)
    x
  end

  def forward_substitution(l, b) do
    {rows, _} = Matrix.size(l)
    y = Matrix.new(rows, 1, 0)

    Enum.reduce(0..(rows - 1), y, fn i, y ->
      y = Matrix.set(y, i, 0, Matrix.elem(b, i, 0) - Enum.reduce(0..(i - 1), 0, fn j, acc -> acc + Matrix.elem(l, i, j) * Matrix.elem(y, j, 0) end))
      y
    end)
  end

  def backward_substitution(u, y) do
    {rows, _} = Matrix.size(u)
    x = Matrix.new(rows, 1, 0)

    Enum.reduce((rows - 1)..0//-1, x, fn i, x ->
      sum = Enum.reduce(0..(i - 1), 0, fn j, acc ->
        acc + Matrix.elem(u, i, j, 0) * Matrix.elem(x, j, 0, 0)
      end)
      divisor = Matrix.elem(u, i, i)
      x = if divisor != 0 do
        x = Matrix.set(x, i, 0, (Matrix.elem(y, i, 0) - sum) / divisor)
        x
      else
        x = Matrix.set(x, i, 0, 0)
        x
      end

      x
    end)
  end

  def solve_system(a, b, :unstable) do
    {rows, cols} = Matrix.size(a)
    augmented_matrix = Matrix.new(rows, cols + 1)

    augmented_matrix = Enum.reduce(0..(rows - 1), augmented_matrix, fn i, augmented_matrix ->
      augmented_matrix = Enum.reduce(0..(cols - 1), augmented_matrix, fn j, augmented_matrix ->
        Matrix.set(augmented_matrix, i, j, Matrix.elem(a, i, j))
      end)
      Matrix.set(augmented_matrix, i, cols, Matrix.elem(b, i, 0))
    end)
    row_echelon_form = gauss_elimination(augmented_matrix)
    x = backward_substitution_for_gauss(row_echelon_form)
    x
  end

  def backward_substitution_for_gauss(matrix_echelon_form) do
    {rows, cols} = Matrix.size(matrix_echelon_form)
    x = Matrix.new(rows, 1, 0)

    Enum.reduce((rows - 1)..0//-1, x, fn i, x ->
      sum = Enum.reduce((i + 1)..(cols - 2), 0, fn j, acc ->
        acc + Matrix.elem(matrix_echelon_form, i, j) * Matrix.elem(x, j, 0, 0)
      end)
      x = Matrix.set(x, i, 0, (Matrix.elem(matrix_echelon_form, i, cols - 1) - sum) / Matrix.elem(matrix_echelon_form, i, i))
      x
    end)
  end

  def solve_system(a, b, :stable) do
    {rows, cols} = Matrix.size(a)

    augmented_matrix = Matrix.new(rows, cols + 1)


    augmented_matrix = Enum.reduce(0..(rows - 1), augmented_matrix, fn i, augmented_matrix ->
      augmented_matrix = Enum.reduce(0..(cols - 1), augmented_matrix, fn j, augmented_matrix ->
        Matrix.set(augmented_matrix, i, j, Matrix.elem(a, i, j))
      end)
      Matrix.set(augmented_matrix, i, cols, Matrix.elem(b, i, 0))
    end)
    row_echelon_form = gauss_elimination_with_pivot(augmented_matrix)
    x = backward_substitution_for_gauss(row_echelon_form)
    x
  end
end

defmodule GaussMatrixComputations do
  def one do
    IO.inspect("ZAD 1")
    matrix = GaussMatrix.random_matrix()
    vector = GaussMatrix.result_vector()
    Matrix.pretty_print(matrix, "%d", " ")
    Matrix.pretty_print(vector, "%d", " ")
    Matrix.pretty_print(GaussMatrix.solve_system(matrix, vector, :unstable))
  end

  def two do
    IO.inspect("ZAD 2")
    matrix = GaussMatrix.random_matrix()
    vector = GaussMatrix.result_vector()
    Matrix.pretty_print(matrix, "%d", " ")
    Matrix.pretty_print(vector, "%d", " ")
    Matrix.pretty_print(GaussMatrix.solve_system(matrix, vector, :stable))
  end

  def three do
    IO.inspect("ZAD 3")
    matrix = GaussMatrix.random_matrix()
    vector = GaussMatrix.result_vector()
    Matrix.pretty_print(matrix, "%d", " ")
    Matrix.pretty_print(vector, "%d", " ")
    Matrix.pretty_print(GaussMatrix.solve_system_lu(matrix, vector, :unstable))
  end

  def four do
    IO.inspect("ZAD 4")
    matrix = GaussMatrix.random_matrix()
    vector = GaussMatrix.result_vector()
    Matrix.pretty_print(matrix, "%d", " ")
    Matrix.pretty_print(vector, "%d", " ")
    Matrix.pretty_print(GaussMatrix.solve_system_lu(matrix, vector, :stable))
  end
end

GaussMatrixComputations.one()
GaussMatrixComputations.two()
GaussMatrixComputations.three()
GaussMatrixComputations.four()
