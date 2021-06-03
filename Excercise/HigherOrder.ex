defmodule Cards do
  @type suite :: :spade | :heart | :diamond | :club
  @type value :: 2..14
  @type card :: {:card, suite, value}

  @spec sort([card],fun()) :: [card]
  @spec split([card]) :: {[card], [card]}
  @spec merge([card], [card], fun()) :: [card]

  def test() do
    deck = [{:card, :heart, 5},
    {:card, :heart, 7},
    {:card, :spade, 2},
    {:card, :club, 9},
    {:card, :diamond, 4}
  ]
  sort(deck, fn (c1,c2)-> less_then(c1,c2) end)
  end

  @doc """
  :club < :diamond < :heart < :spade
  """
  def less_then({:card, s, v1},{:card, s, v2}) do v1 < v2 end
  def less_then({:card, :club, _},_) do true end
  def less_then({:card, :diamond, _},{:card, :heart, _}) do true end
  def less_then({:card, :diamond, _},{:card, :spade, _}) do true end
  def less_then({:card, :heart, _},{:card, :spade, _}) do true end
  def less_then({:card, _, _},{:card, _, _}) do false end

  def sort([], _) do [] end
  def sort([c], _) do [c] end
  def sort(deck, op) do
    {d1,d2} = split(deck)
    merge(sort(d1,op),sort(d2,op), op)
  end

  def split([]) do {[], []} end
  def split([c|rest]) do
    {s1, s2 } = split(rest)
    {[c|s2],s1}
  end

  def split_tail_recursive(list) do split_tail_recursive(list, [],[]) end
  def split_tail_recursive([], a, b) do {a,b} end
  def split_tail_recursive([h|t], a, b) do split_tail_recursive(t,b,[h|a]) end


  def merge([], s2, _) do s2 end
  def merge(s1, [], _) do s1 end
  def merge([c1|r1]=s1, [c2|r2]=s2, op) do
    case op.(c1,c2) do
      true -> [c1|merge(r1, s2, op)]
      false -> [c2|merge(s1, r2, op)]
    end
  end
end

defmodule Higher do
@doc """
Some higher order functions...
"""

  def map([], _f) do [] end
  def map([h|t], f) do
    [f.(h)| map(t, f)]
  end

  def filter([], _f) do [] end
  def filter([h|t], f) do
    if f.(h) do
      [h|filter(t, f)]
    else
      filter(t, f)
    end
  end

  def split_with(l,op) do split_with(l,op,[],[]) end
  def split_with([], _op, yes, no) do {yes, no} end
  def split_with([h|t], op, yes, no) do
    if op.(h) do
      split_with(t, op, [h|yes], no)
    else
      split_with(t, op, yes, [h|no])
    end
  end

  def infinity() do
    fn()-> infinity(0) end
  end
  def infinity(n) do
    [n|fn()-> infinity(n+1) end]
  end

  def fib()do
    fn()-> fib(1,1) end
  end
  def fib(f1,f2) do
    [f1|fn()->fib(f2,f1+f2)end]
  end

  def sum(range) do
    reduce(range,{:continue, 0},fn(x, a) -> {:continue, x + a} end)
  end

  def prod(range) do
    reduce(range,{:continue, 1},fn(x, a) -> {:continue, x * a} end)
  end

  def take(range, n) do
    reduce(range, {:continue, {:sofar, 0, []}},
    fn (x, {:sofar, s, acc})->
      s = s+1
      if s >= n do
        {:halt, Enum.reverse([x|acc])}
      else
        {:continue, {:sofar, s, [x|acc]}}
      end
    end
    )
  end

  def head(r) do
    reduce(r, {:continue, :na},
    fn (x,_)->
      {:suspend, x}
    end)
  end

  def reduce({:range, from, to}, {:continue, acc}, fun) do
    if from <= to do
      reduce({:range, from + 1, to}, fun.(from, acc), fun)
    else
      {:done, acc}
    end
  end

  def reduce(range, {:suspend, acc},fun) do
    {:suspended, acc, fn(cmd) -> reduce(range, cmd, fun) end}
  end

  def reduce(_, {:halt, acc}, _) do
    {:halted, acc}
  end
end


defmodule Excercise do
@doc """
Higher order excercise
"""
  def test() do
    list = [1,2,3,4,5]
    f1 = fn (x, acc) -> x + acc end
    f2 = fn (x, acc) -> x * acc end
    f3 = fn (x, acc) -> if x > acc do x else acc end end

    res1 = foldr(list, 0, f1)
    res2 = foldr(list, 1, f2)
    res3 = foldr(list, 0, f3)
    IO.puts("Adds list [1,2,3,4,5]: #{res1}")
    IO.puts("Multiplies list [1,2,3,4,5]: #{res2}")
    IO.puts("Highest number in list [1,2,3,4,5]: #{res3}")
  end

  def foldr([], acc, _op) do acc end
  def foldr([h|t], acc, op) do
    op.(h, foldr(t, acc, op))
  end

  def foldl([], acc, _op) do acc end
  def foldl([h|t], acc, op) do
    foldl(t, op.(h, acc), op)
  end

  def reverse(l) do
    f = fn (h, a) -> a ++ [h] end
    foldr(l,[],f)
  end

  def reverse_tail_recursive(l) do
    f = fn (h, a) -> [h|a] end
    foldl(l, [], f)
  end

  def append_right(l) do
    f = fn (h,a) -> h ++ a end
    foldr(l, [], f)
  end

  def append_left(l) do
    f = fn (h,a) -> a ++ h end
    foldl(l, [], f)
  end

end

defmodule Car do
  def m1() do
    {:car, "VW",
  [{:model, "Typ-1"}, {:year, 1964}, {:engine, "1300"},
  {:cyl, 4}, {:vol, 1300}, {:power, 40}, {:fuel, 46}, {:acc, 12.8}]}
  end

  def brand_model({:car, brand, prop}) do
    case List.keyfind(prop, :model, 0) do
      nil -> brand
      {:model, model} -> "#{brand} #{model}"
    end
  end

  def m1_maps() do
    {:car, "VW",
    %{:model => "Typ-1", :year => 1964, :engine => "1300",
    :cyl => 4, :vol => 1300, :power => 40, :fuel => 46, :acc => 12.8}}
  end

  def brand_model_maps({:car, brand, prop}) do
    case prop do
      %{:model => model} -> "#{brand} #{model}"
      _ -> brand
    end
  end

  defstruct brand: "", year: :na, model: "unknown", cyl: :na, power: :na

  def m1_struct() do
    %Car{:brand => "SAAB", :model => "96 V4", :year => 1974, :power => 65, :cyl => 4}
  end

  def brand_model_struct(%Car{brand: brand, model: model}) do
    "#{brand} #{model}"
  end

  def year_struct(car = %Car{}) do
    car.year
  end
end

defmodule Dog do
  defstruct name: "", year: 2020

  def fido() do
    %Dog{name: "Fido", year: 2018}
  end

  def year_struct(what) do
    what.year
  end
end
