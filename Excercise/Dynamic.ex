defmodule MaxProfit do

  @type hinge :: hinge
  @type latch :: latch
  @spec search(integer, integer, hinge, latch) :: {integer, integer, integer}

  def search(m, t, {hm,ht,hp} = h, {lm, lt, lp} = l) when (m >=hm) and (t >= ht) and (m >= lm) and (t >= lt) do
    #we have material to make either a hinge or a latch
    {hi, li, pi} = search((m-hm), (t-ht), h, l)
    {hj, lj, pj} = search((m-lm), (t-lt), h, l)

    #Which alternative will give us the max profit
    if((pi + hp) > (pj + lp)) do
      #make hinge
      {(hi + 1), li, (pi+hp)}
    else
      #make latch
      {hj, (lj + 1), (pj+lp)}
    end
  end

  def search(m, t, {hm,ht,hp} = h, l) when (m >= hm) and (t >= ht) do
    #We can make a hinge
    {hn, ln, p} = search((m-hm), (t-ht), h, l)
    {(hn + 1), ln, (p + hp)}
  end

  def search(m, t, h, {lm, lt, lp} = l) when (m >= lm) and (t >= lt) do
    {hn, ln, p} = search((m-lm), (t-lt), h, l)
    {hn, (ln + 1), (p + lp)}
  end

  def search(_,_,_,_) do
    #We can make neither
    {0,0,0}
  end
end

defmodule Better_MaxProfit do

  @type hinge :: hinge
  @type latch :: latch
  @spec search(integer, integer, hinge, latch) :: {integer, integer, integer}

  def search(m, t, {hm,ht,hp} = h, {lm, lt, lp} = l, mem) when (m >=hm) and (t >= ht) and (m >= lm) and (t >= lt) do
    #we have material to make either a hinge or a latch
    {hi, li, pi, mem} = check((m-hm), (t-ht), h, l, mem)
    {hj, lj, pj, mem} = check((m-lm), (t-lt), h, l, mem)

    #Which alternative will give us the max profit
    if((pi + hp) > (pj + lp)) do
      #make hinge
      {(hi + 1), li, (pi+hp), mem}
    else
      #make latch
      {hj, (lj + 1), (pj+lp), mem}
    end
  end

  def search(m, t, {hm,ht,hp} = h, l, mem) when (m >= hm) and (t >= ht) do
    #We can make a hinge
    {hn, ln, p, mem} = check((m-hm), (t-ht), h, l,mem)
    {(hn + 1), ln, (p + hp), mem}
  end

  def search(m, t, h, {lm, lt, lp} = l, mem) when (m >= lm) and (t >= lt) do
    {hn, ln, p, mem} = check((m-lm), (t-lt), h, l, mem)
    {hn, (ln + 1), (p + lp), mem}
  end

  def search(_,_,_,_,_) do
    #We can make neither
    {0,0,0}
  end
  #Let's add a memory to the search function
  def memory(material, time hinge, latch) do
    mem = Memory.new()
    {solution, _} = search(material, time, hinge, latch, mem)
    solution
  end

  def check(material, time, hinge, latch, mem) do
    case Memory.lookup({material, time}, mem) do
      nil -> #No previous solution found
      {solution, mem} search(material, time, hinge, latch, mem)
      {solution, Memory.store({material, time}, solution, mem)}
      found-> {found, mem}
    end
  end

end

defmodule Memory do

  def new() do
    []
  end

  def store(k, v, mem) do
    [{k, v} | mem]
  end

  def lookup(_, []) do nil end
  def lookup(k, [{k, v}|_]) do v end
  def lookup(k, [_|rest]) do lookup(k, rest) end
end

defmodule Fibonacci do
  #O(1,6^2)
  def fib_naive(0) do 0 end
  def fib_naive(1) do 1 end
  def fib_naive(n) do
    fib(n-1) + fib(n-2)
  end
  #O(n)
  def fib(0) do {0, nil} end
  def fib(1) do {1,0} end
  def fib(n) do
    {n1,n2} = fib(n-1)
    {n1+n2,n1}
  end

end

defmodule ShortestPath do

  def dynamic(from, to, graph) do
    mem = Memory.new()
    {solution, _} = shortest(from, to, graph, mem)
    solution
  end
  def shortest(from, from, _, mem) do {{0, []}, mem} end

  def shortest(from, to, graph, mem) do
    next = Graph.next(from, graph)
    {distances, mem} = distances(next, to, graph, mem)
    shortest = select(distances)
    {shortest, mem}
  end

  def distances(next, to, graph, mem) do
    List.foldl(next, {[], mem}, fn({t,d}, {dis, mem}=acc)->
      case check(t, to, graph, mem) do
        {{:inf, _}, _} -> acc
        {{n, path}, mem} -> {[{d+n, [t|path]}|dis], mem}
      end
    end)
  end

  def select(distances) do
    List.foldl(distances, {:inf, nil}, fn({d, _}=s, {ad, _}=acc)->
      if d < ad do
        s
      else
        acc
      end
    end)
  end

  def check(from, to, graph,mem) do
    case Memory.lookup(from, mem) do
      nil -> {solution, mem} = shortest(from, to, graph, mem)
      {solution, Memory.store(from, solution, mem)}
      solution -> {solution, mem}
    end
  end
end

defmodule Graph do

  def sample() do
    new([a: [b: 2, d: 5], b: [c: 2, e: 3], d: [f: 2, c: 3],
    f: [c: 1, g: 3], c: [g: 1, e: 6], e: [g: 2], g: []])
  end

  def new(nodes) do
    Map.new(nodes)
  end

  def next(from, map) do
    Map.get(map, from, [])
  end


end
