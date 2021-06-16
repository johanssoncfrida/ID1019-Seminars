defmodule Eros do
  @doc """
  Generates a list of primes up to a given limit.
  """
  @spec primes_to(non_neg_integer) :: [non_neg_integer]
  def primes_to(limit) do
    list = generate_nums(2, limit)
    r = make_ref()
    filter_by_list(Enum.take(list, div(limit, 2)), list, r)
  end

  def generate_nums(from, to) do Enum.to_list(from..to) end

  def filter_by_list([], filtered_list,_) do filtered_list end
  def filter_by_list([h | t], filtered_list, r) do
    parallel(fn() -> filter_by_list(t, Enum.filter(filtered_list, &(rem(&1, h) != 0 || &1 == h)),make_ref()) end, r)
    collect(r)
  end

  def parallel(fun, ref) do
    self = self()
    spawn(fn() ->
      res = fun.()
      send(self, {:ok, ref, res})
    end)
  end

  def collect(ref) do
    receive do
      {:ok, ^ref, res} -> res
    end
  end
end
