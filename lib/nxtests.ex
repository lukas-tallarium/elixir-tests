defmodule NxTests do

  alias Nx

  def pinv(x, y) do
    Nx.LinAlg.pinv(x) |> Nx.dot(y)
  end

  def mat(x, y) do
    x
    |> Nx.transpose()
    |> Nx.dot(x)
    |> Nx.LinAlg.invert()
    |> Nx.dot(Nx.transpose(x))
    |> Nx.dot(y)
  end

  def jit_single() do

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

  def pinv_loop(x, y) do
    x
    |> Enum.chunk_every(15, 1, :discard)
    |> Enum.map(fn window ->
      window_t = window |> Nx.tensor()
      pinv(window_t, y)
    end)
    0
  end
    
  def mat_loop(x, y) do
    x
    |> Enum.chunk_every(15, 1, :discard)
    |> Enum.map(fn window ->
      window_t = window |> Nx.tensor()
      mat(window_t, y)
    end)
    0
  end
    
  def jit_loop_test() do

    x1 = 1..1500 |> Range.to_list()
    x2 = 1..3000//2 |> Range.to_list() |> Enum.map(fn x -> x*(x+1) end)
    x = Enum.zip(x1, x2)
    |> Enum.map(fn {x1, x2} ->
      [x1, x2]
    end)
      
    y = 1..30//2 |> Range.to_list() |> Enum.map(fn y -> y*y end) |> Nx.tensor()

    pinv_jit = Nx.Defn.jit(fn x, y -> pinv_loop(x, y) end, compiler: EXLA)
    mat_jit = Nx.Defn.jit(fn x, y -> mat_loop(x, y) end, compiler: EXLA)
    
    "first run" |> IO.inspect()
    fn -> pinv_loop(x, y) end |> :timer.tc() |> IO.inspect()
    fn -> mat_loop(x, y) end |> :timer.tc() |> IO.inspect()
    fn -> pinv_jit.(x, y) end |> :timer.tc() |> IO.inspect()
    fn -> mat_jit.(x, y) end |> :timer.tc() |> IO.inspect()

    "second run" |> IO.inspect()
    fn -> pinv_loop(x, y) end |> :timer.tc() |> IO.inspect()
    fn -> mat_loop(x, y) end |> :timer.tc() |> IO.inspect()
    fn -> pinv_jit.(x, y) end |> :timer.tc() |> IO.inspect()
    fn -> mat_jit.(x, y) end |> :timer.tc() |> IO.inspect()
    

    "third run" |> IO.inspect()
    x1 = 1..1500 |> Range.to_list() |> Enum.map(fn x -> 3*x end)
    x2 = 1..3000//2 |> Range.to_list() |> Enum.map(fn x -> x*(x+1) end)
    x = Enum.zip(x1, x2)
    |> Enum.map(fn {x1, x2} ->
      [x1, x2]
    end)
    fn -> pinv_loop(x, y) end |> :timer.tc() |> IO.inspect()
    fn -> mat_loop(x, y) end |> :timer.tc() |> IO.inspect()
    fn -> pinv_jit.(x, y) end |> :timer.tc() |> IO.inspect()
    fn -> mat_jit.(x, y) end |> :timer.tc() |> IO.inspect()

    :ok
  end

end
