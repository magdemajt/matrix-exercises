defmodule ComputationsNorms do
  def main() do
    matrix = [[4, 9, 2], [3, 5, 7], [8, 1, 6]]

    IO.puts("Norma macierzowa ||M||1")
    IO.puts(Norms.norm_m_1(matrix))
    IO.puts("\n")

    IO.puts("Współczynnik uwarunkowania macierzowy ||M||1")
    IO.puts(Norms.cond_m_1(matrix))
    IO.puts("\n")

    IO.puts("Norma macierzowa ||M||2")
    IO.puts(Norms.norm_m_2(matrix))
    IO.puts("\n")

    IO.puts("Współczynnik uwarunkowania macierzowy ||M||2")
    IO.puts(Norms.cond_m_2(matrix))
    IO.puts("\n")

    IO.puts("Norma macierzowa ||M||p")
    IO.puts("dla p=3")
    IO.puts(Norms.norm_m_p(matrix, 3))
    IO.puts("\n")

    IO.puts("dla p=50")
    IO.puts(Norms.norm_m_p(matrix, 50))
    IO.puts("\n")

    IO.puts("dla p=100")
    IO.puts(Norms.norm_m_p(matrix, 100))
    IO.puts("\n")

    IO.puts("dla p=200")
    IO.puts(Norms.norm_m_p(matrix, 200))
    IO.puts("\n")

    IO.puts("Współczynnik uwarunkowania macierzowy ||M||p")
    IO.puts("dla p=3")
    IO.puts(Norms.cond_m_p(matrix, 3))
    IO.puts("\n")

    IO.puts("dla p=50")
    IO.puts(Norms.cond_m_p(matrix, 50))
    IO.puts("\n")

    IO.puts("dla p=100")
    IO.puts(Norms.cond_m_p(matrix, 100))
    IO.puts("\n")


    IO.puts("dla p=200")
    IO.puts(Norms.cond_m_p(matrix, 200))
    IO.puts("\n")

    IO.puts("Norma macierzowa ||M||inf")
    IO.puts(Norms.norm_m_inf(matrix))
    IO.puts("\n")

    IO.puts("Współczynnik uwarunkowania macierzowy ||M||inf")
    IO.puts(Norms.cond_m_p(matrix, :inf))
    IO.puts("\n")

    {u, sig, v} = Norms.svd(matrix)
    Matrix.pretty_print(u, "%d", " ")
    Matrix.pretty_print(sig, "%d", " ")
    Matrix.pretty_print(v, "%d", " ")
  end
end
