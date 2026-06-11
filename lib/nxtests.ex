defmodule NxTests do

  alias Nx

  def pinv(x, y) do
    Nx.LinAlg.pinv(x) |> Nx.dot(y)
  end

  def mat(x, y) do
    x |> Nx.transpose() |> Nx.dot(x) |> Nx.LinAlg.invert() |> Nx.dot(Nx.transpose(x)) |> Nx.dot(y)
  end

  def func() do

    x = Nx.tensor([[1.0, 2.0], [4.0, 5.0], [10.0, 11.0]])
    
    y = Nx.tensor([1.0, 2.0, 3.0])
    
    pinv_jit = Nx.Defn.jit(fn x, y -> pinv(x, y) end, compiler: EXLA)
    mat_jit = Nx.Defn.jit(fn x, y -> mat(x, y) end, compiler: EXLA)

    "first run" |> IO.inspect()
    fn -> pinv(x, y) end |> :timer.tc() |> IO.inspect()
    fn -> mat(x, y) end |> :timer.tc() |> IO.inspect()
    fn -> pinv_jit.(x, y) end |> :timer.tc() |> IO.inspect()
    fn -> mat_jit.(x, y) end |> :timer.tc() |> IO.inspect()

    "second run" |> IO.inspect()
    fn -> pinv(x, y) end |> :timer.tc() |> IO.inspect()
    fn -> mat(x, y) end |> :timer.tc() |> IO.inspect()
    fn -> pinv_jit.(x, y) end |> :timer.tc() |> IO.inspect()
    fn -> mat_jit.(x, y) end |> :timer.tc() |> IO.inspect()

    :ok
  end
end
