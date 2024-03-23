

defmodule Gauss do
  @matrix_size (10 + 2)

  def gauss_elimination(matrix) do
    for i <- 0..(length(matrix) - 2) do
      for j <- (i + 1)..(length(matrix) - 1) do
        factor = Enum.at(Enum.at(matrix, j), i) / Enum.at(Enum.at(matrix, i), i)
        matrix = update_row(matrix, j, i, factor)
      end
    end
    matrix
  end

  defp update_row(matrix, row, col, factor) do
    old_row = Enum.at(matrix, row)
    subtract_row = Enum.map(Enum.at(matrix, col), fn x -> x * factor end)
    new_row = Enum.zip_with(old_row, subtract_row, &(&1 - &2))
    Enum.map(matrix, fn r -> if r == old_row, do: new_row, else: r end)
  end

  def gauss_elimination_with_pivot(matrix) do
    for i <- 0..(length(matrix) - 2) do
      matrix = pivot(matrix, i)
      for j <- (i + 1)..(length(matrix) - 1) do
        factor = Enum.at(Enum.at(matrix, j), i) / Enum.at(Enum.at(matrix, i), i)
        matrix = update_row(matrix, j, i, factor)
      end
    end
    matrix
  end

  defp pivot(matrix, col) do
    max_row = Enum.max_by(col..(length(matrix) - 1), fn row -> Enum.at(Enum.at(matrix, row), col) |> abs end)
    swapped_row = Enum.at(matrix, 0)
    if max_row != swapped_row do
      matrix = List.replace_at(matrix, Enum.find_index(matrix, swapped_row), Enum.at(matrix, max_row))
      matrix = List.replace_at(matrix, 0, Enum.at(matrix, max_row))
    end
  end

  def random_matrix do
    Enum.map(1..@matrix_size, fn _ -> Enum.map(1..@matrix_size, fn _ -> :rand.uniform(100) end) end)
  end

  def result_vector do
    Enum.map(1..@matrix_size, fn _ -> :rand.uniform(100) end)
  end

  def lu_decomposition(matrix) do
    {l, u} = Enum.reduce(0..(length(matrix) - 1), {identity_matrix(length(matrix)), matrix}, fn i, {l, u} ->
      {l, u} = Enum.reduce(i..(length(matrix) - 1), {l, u}, fn j, {l, u} ->
        factor = u[j][i] / u[i][i]
        l = List.replace_at(l, j, List.replace_at(Enum.at(l, j), i, factor))
        u = List.replace_at(u, j, Enum.zip_with(Enum.at(u, j), Enum.map(Enum.at(u, i), &(&1 * factor)), &(&1 - &2)))
        {l, u}
      end)
      {l, u}
    end)
    {l, u}
  end

  def lu_decomposition_with_pivot(matrix) do
    {l, u, p} = Enum.reduce(0..(length(matrix) - 1), {identity_matrix(length(matrix)), matrix, identity_matrix(length(matrix))}, fn i, {l, u, p} ->
      {l, u, p} = pivot(l, u, p, i)
      {l, u} = Enum.reduce(i..(length(matrix) - 1), {l, u}, fn j, {l, u} ->
        factor = u[j][i] / u[i][i]
        l = List.replace_at(l, j, List.replace_at(Enum.at(l, j), i, factor))
        u = List.replace_at(u, j, Enum.zip_with(Enum.at(u, j), Enum.map(Enum.at(u, i), &(&1 * factor)), &(&1 - &2)))
        {l, u}
      end)
      {l, u, p}
    end)
    {l, u, p}
  end

  defp pivot(l, u, p, col) do
    max_row = Enum.max_by(col..(length(u) - 1), fn row -> Enum.at(Enum.at(u, row), col) |> abs end)
    if max_row != col do
      u = List.swap_at(u, col, max_row)
      p = List.swap_at(p, col, max_row)
      l = List.swap_at(l, col, max_row)
    end
    {l, u, p}
  end

  defp identity_matrix(size) do
    Enum.map(0..(size - 1), fn i -> Enum.map(0..(size - 1), fn j -> if(i == j, do: 1, else: 0) end) end)
  end

  def solve_system(a, b, :unstable) do
    # Augment the matrix A with the vector b
    augmented_matrix = Enum.zip_with(a, b, fn row, elem -> row ++ [elem] end)

    # Perform Gauss elimination
    row_echelon_form = gauss_elimination(augmented_matrix)

    # Perform back substitution
    x = back_substitution(row_echelon_form)

    x
  end

  def solve_system(a, b, :stable) do
    # Augment the matrix A with the vector b
    augmented_matrix = Enum.zip_with(a, b, fn row, elem -> row ++ [elem] end)

    # Perform Gauss elimination with pivot
    row_echelon_form = gauss_elimination_with_pivot(augmented_matrix)

    # Perform back substitution
    x = back_substitution(row_echelon_form)

    x
  end

  defp back_substitution(matrix) do
    n = length(matrix)
    x = List.duplicate(0, n)

    for i <- (n - 1)..0..-1 do
      sum = Enum.at(Enum.at(matrix, i), n)
      for j <- (i + 1)..(n - 1) do
        sum = sum - Enum.at(Enum.at(matrix, i), j) * Enum.at(x, j)
      end
      x = List.replace_at(x, i, sum / Enum.at(Enum.at(matrix, i), i))
    end

    x
  end

  defp back_substitution(u, y) do
    n = length(u)
    x = List.duplicate(0, n)

    for i <- (n - 1)..0..-1 do
      sum = Enum.at(y, i)
      for j <- (i + 1)..(n - 1) do
        sum = sum - Enum.at(Enum.at(u, i), j) * Enum.at(x, j)
      end
      x = List.replace_at(x, i, sum / Enum.at(Enum.at(u, i), i))
    end

    x
  end

  def solve_system_lu(a, b, :unstable) do
    {l, u} = lu_decomposition(a)

    # Solve Ly = b for y using forward substitution
    y = forward_substitution(l, b)

    # Solve Ux = y for x using back substitution
    x = back_substitution(u, y)

    x
  end

  def solve_system_lu(a, b, :stable) do
    {l, u, p} = lu_decomposition_with_pivot(a)

    # Apply the permutation matrix P to b
    b = Enum.map(p, &Enum.at(b, &1))

    # Solve Ly = Pb for y using forward substitution
    y = forward_substitution(l, b)

    # Solve Ux = y for x using back substitution
    x = back_substitution(u, y)

    x
  end

  defp forward_substitution(l, b) do
    n = length(l)
    y = List.duplicate(0, n)

    for i <- 0..(n - 1) do
      sum = Enum.at(b, i)
      for j <- 0..(i - 1) do
        sum = sum - Enum.at(Enum.at(l, i), j) * Enum.at(y, j)
      end
      y = List.replace_at(y, i, sum / Enum.at(Enum.at(l, i), i))
    end

    y
  end

end

defmodule GaussComputations do
  def one do
    matrix = Gauss.random_matrix()
    vector = Gauss.result_vector()
    IO.inspect(matrix)
    IO.inspect(vector)

    IO.inspect(Gauss.solve_system(matrix, vector, :unstable))
  end

  def two do
    matrix = Gauss.random_matrix()
    vector = Gauss.result_vector()
    IO.inspect(matrix)
    IO.inspect(vector)

    IO.inspect(Gauss.solve_system(matrix, vector, :stable))
  end

  def three do
    matrix = Gauss.random_matrix()
    vector = Gauss.result_vector()
    IO.inspect(matrix)
    IO.inspect(vector)

    IO.inspect(Gauss.solve_system_lu(matrix, vector, :unstable))
  end

  def four do
    matrix = Gauss.random_matrix()
    vector = Gauss.result_vector()
    IO.inspect(matrix)
    IO.inspect(vector)

    IO.inspect(Gauss.solve_system_lu(matrix, vector, :stable))
  end

end
