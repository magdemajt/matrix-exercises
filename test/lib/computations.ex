defmodule Computations do
  def main do
    ks = 2..16
    ls = [4, 32, 256]

    for k <- ks, do: (for l <- ls, do: compute(k, l))
  end

  def compute(k, l) do
    size = Integer.pow(2, k)
    matrix1 = for _ <- 1..size, do: (for _ <- 1..size, do: Enum.random(1..1_000))
    matrix2 = for _ <- 1..size, do: (for _ <- 1..size, do: Enum.random(1..1_000))
    start = System.os_time(:millisecond)
    {_, agent} = Matrix.multiply_strassen(matrix1, matrix2, l)
    fin = System.os_time(:millisecond)
    IO.inspect(Agent.get(agent, &(&1)))
    res = Agent.get(agent, &(&1).additions) + Agent.get(agent, &(&1).multiplications) + Agent.get(agent, &(&1).subtractions)
    IO.puts("#{res} ")
    File.write("results.csv", "#{res},#{fin-start}\n", [:append])
  end
end
