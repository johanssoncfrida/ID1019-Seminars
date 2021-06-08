defmodule SplayTree do

  def update(nil, key, value) do
    {:node, key, value, nil, nil}
  end

  def update({:node, key, _, a, b}, key, value) do
    {:node, key, value, a, b}
  end

 #      y                                     x
 #     / \       Zig (Right Rotation)        /  \
 #    x   c      – - – - – - – - - ->       a    y
 #   / \         < - - - - - - - - -            / \
 #  a   b        Zag (Left Rotation)           b   c

  def update({:node, rk, rv, zig, c}, key, value) when key < rk do
    # The general rule where we will do the Zig transformation.
    {:splay, _, a, b} = splay(zig, key)
    {:node, key, value, a, {:node, rk, rv, b, c}}
  end

  def update({:node, rk, rv, a, zag}, key, value) when key >= rk do
    # The general rule where we will do the Zag transformation.
    {:splay, _, b, c} = splay(zag, key)
    {:node, key, value, {:node, rk, rv, a, b}, c}
  end

  defp splay(nil, _) do
    {:splay, :na, nil, nil}
  end

  defp splay({:node, key, value, a, b}, key) do
    {:splay, value, a, b}
  end

  defp splay({:node, rk, rv, nil, b}, key) when key < rk do
    # Should go left, but the left branch empty.
    {:splay, :na, nil, {:node, rk, rv, nil, b}}
  end
  defp splay({:node, rk, rv, a, nil}, key) when key >= rk do
    # Should go right, but the right branch empty.
    {:splay, :na, {:node, rk, rv, a, nil}, nil}
  end

  defp splay({:node, rk, rv, {:node, key, value, a, b}, c}, key) do
    # Found to the left.
    {:splay, value, a, {:node, rk, rv, b, c}}
  end

  defp splay({:node, rk, rv, a, {:node, key, value, b, c}}, key) do
    # Found to the right.
    {:splay, value, {:node, rk, rv, a, b}, c}
  end

  defp splay({:node, gk, gv, {:node, pk, pv, zig_zig, c}, d}, key)
    when key < gk and key < pk do
    # Going down left-left, this is the so called zig-zig case.
    {:splay, value, a, b} = splay(zig_zig, key)
    {:splay, value, a, {:node, pk, pv, b, {:node, gk, gv, c, d}}}
  end

  defp splay({:node, gk, gv, {:node, pk, pv, a, zig_zag}, d}, key)
    when key < gk and key >= pk do
    # Going down left-right, this is the so called zig-zag case.
    {:splay, value, b, c} = splay(zig_zag, key)
    {:splay, value, {:node, pk, pv, a, b}, {:node, gk, gv, c, d}}
  end

  defp splay({:node, gk, gv, a, {:node, pk, pv, zag_zig, d}}, key)
    when key >= gk and key < pk do
      {:splay, value, b, c} = splay(zag_zig, key)
    {:splay, value, {:node, gk, gv, a, b}, {:node, pk, pv, c, d}}
  end

defp splay({:node, gk, gv, a, {:node, pk, pv, b, zag_zag}}, key)
    when key >= gk do
      {:splay, value, c, d} = splay(zag_zag, key)
    {:splay, value, {:node, pk, pv, {:node, gk, gv, a, b}, c}, d}
  end

  def test() do
    insert = [{3, :c}, {5, :e}, {2, :b}, {1, :a}, {7, :g}, {4, :d}, {5, :e}]
    empty = nil
    List.foldl(insert, empty, fn({k, v}, t) -> update(t, k, v) end)
  end

end
