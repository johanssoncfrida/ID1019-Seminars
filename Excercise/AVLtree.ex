defmodule AVLTree do

  @type key :: key
  @type value :: integer
  @difference :: integer
  @spec tree :: {:node, key, value, difference, left, right}
  @spec empty tree :: nil

  def insert(tree, key, value) do
    case insrt(tree, key, value) do
    {:inc, q} -> q
    {:ok, q} -> q
    end
  end

  def insrt(nil, key, value) do
    {:inc, {:node, key, value, 0 nil, nil}}
  end
  def insrt({:node, key, _, diff, left, right}, key, value) do
    {:ok, {:node, key, value, diff, left, right}}
  end

  defp insrt({:node, rk, rv, 0, left, right}, kk, kv) when kk < rk do
    case insrt(left, kk, kv) do
    {:inc, q} ->
        {:inc, {:node, rk, rv, -1, q, right}}
    {:ok, q} ->
        {:ok, {:node, rk, rv, 0, q, right}}
    end
  end

  defp insrt({:node, rk, rv, 0, left, right}, kk, kv) do
    case insrt(right, kk, kv) do
    {:inc, q} ->
        {:inc, {:node, rk, rv, 0, q, right}}
    {:ok, q} ->
        {:ok, {:node, rk, rv, +1, q, right}}
    end
  end

  defp insrt({:node, rk, rv, +1, left, right}, kk, kv) when kk < rk do
    case insrt(left, kk, kv) do
    {:inc, q} ->
        {:ok, {:node, rk, rv, 0, q, right}}
    {:ok, q} ->
        {:ok, {:node, rk, rv, +1, q, right}}
    end
  end

  defp insrt({:node, rk, rv, +1, left, right}, kk, kv) do
    case insrt(right, kv, kv) do
    {:inc, q} ->
        {:ok, {:node, rk, rv, +2, q, right}}
    {:ok, q} ->
        {:ok, {:node, rk, rv, +1, q, right}}
    end
  end

  defp insrt({:node, rk, rv, -1, left, right}, kk, kv) when kk < rk do
    case insrt(left, kk, kv) do
    {:inc, q} ->
        {:ok, rotate({:node, rk, rv, -2, q, right})}
    {:ok, q} ->
        {:ok, {:node, rk, rv, -1, q, right}}
    end
  end

  defp insrt({:node, rk, rv, -1, left, right}, kk, kv) do
    case insrt(right, kk, kv) do
    {:inc, q} ->
        {:ok, rotate({:node, rk, rv, 0, q, right})}
    {:ok, q} ->
        {:ok, {:node, rk, rv, -1, q, right}}
    end
  end

  defp rotate({:node, xk, xv, -2, {:node, yk, yv, -1, lb, rb}, right}) do
    {:node, yk, yv, 0, lb, {:node, xk, xv, 0, rb, right}}
  end

  defp rotate({:node, xk, xv, +2, left, {:node, yk, yv, +1, lb, rb}}) do
      {:node, yk, yv, 0, {:node, xk, xv, 0, left, lb}, rb}
  end

  defp rotate({:node, xk, xv, -2, {:node, yk, yv, +1, llb,
  {:node, zk, zv, -1, lrlb, lrrb}}, rb}) do
      {:node, zk, zv, 0, {:node, yk, yv, 0, llb, lrlb}, {:node, xk, xv, +1, lrrb, rb}}
  end

  defp rotate({:node, xk, xv, -2, {:node, yk, yv, +1, llb,
  {:node, zk, zv, +1, lrlb, lrrb}}, rb}) do
      {:node, zk, zv, 0, {:node, yk, yv, -1, llb, lrlb}, {:node, xk, xv, 0, lrrb, rb}}
  end

  defp rotate({:node, xk, xv, -2, {:node, yk, yv, +1, llb,
  {:node, zk, zv, 0, lrlb, lrrb}}, rb}) do
      {:node, zk, zv, 0, {:node, yk, yv, 0, llb, lrlb}, {:node, xk, xv, 0, lrrb, rb}}
  end

  defp rotate({:node, xk, xv, +2, lb,{:node, yk, yv, -1,
  {:node, zk, zv, +1, rllb, rlrb},rrb}}) do
      {:node, zk, zv, 0, {:node, xk, xv, -1, lb, rllb}, {:node, yk, yv, 0, rlrb, rrb}}
  end

  defp rotate({:node, xk, xv, +2, lb,{:node, yk, yv, -1,
  {:node, zk, zv, -1, rllb, rlrb},rrb}}) do
      {:node, zk, zv, 0, {:node, xk, xv, 0, lb, rllb}, {:node, yk, yv, +1, rlrb, rrb}}
  end

  defp rotate({:node, xk, xv, +2, lb,{:node, yk, yv, -1,
  {:node, zk, zv, +1, rllb, rlrb},rrb}}) do
      {:node, zk, zv, 0, {:node, xk, xv, 0, lb, rllb}, {:node, yk, yv, 0, rlrb, rrb}}
  end
end
