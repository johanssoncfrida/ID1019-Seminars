@doc """
Metainterpreter seminar 2 ID1019
"""
defmodule MetaInterpreter do

  def metainterpreter do
    seq = [{:match, {:var, :x}, {:atm,:a}},
        {:match, {:var, :y}, {:cons, {:var, :x}, {:atm, :b}}},
        {:match, {:cons, :ignore, {:var, :z}}, {:var, :y}},
        {:var, :z}]

    seq2 = [{:match, {:var, :x}, {:atm, :a}},
           {:case, {:var, :x},
           [{:clause, {:atm, :b}, [{:atm, :ops}]},
           {:clause, {:atm, :a}, [{:atm, :yes}]}
           ]}
          ]

    seq3 = [{:match, {:var, :x}, {:atm, :a}},
    {:match, {:var, :f},
        {:lambda, [:y], [:x], [{:cons, {:var, :x}, {:var, :y}}]}},
    {:apply, {:var, :f}, [{:atm, :b}]}
    ]

    res1 = Eager.eval(seq)
    IO.inspect(res1)
    res2 = Eager.eval_seq(seq2, [])
    IO.inspect(res2)
    res3 = Eager.eval_seq(seq3, [])
    IO.inspect(res3)
  end
end

@doc """
Environment with helper functions to Metainterpreters Eager module.
"""
defmodule Env do

  def new() do [] end

  def add(id, str, env) do [{id,str}|env] end

  def lookup(id, [{id, str}|_]) do {id, str} end
  def lookup(id, [{_,_}|rest]) do lookup(id, rest) end
  def lookup(_, []) do :nil end

  def remove(id, [{id, _}| rest]) do remove(id, rest) end
  def remove(id, [{_, _} = head | rest]) do [head | remove(id, rest)] end
  def remove(_, []) do [] end

  def closure(ids, env) do
    List.foldr(ids, [], fn id, acc ->
      case acc do
        :error -> :error
        cls -> case lookup(id, env) do
            {id, value} -> [{id, value} | cls]
            nil -> :error
          end
      end
    end)
  end

  def args(par, strs, env) do
    List.zip([par, strs]) ++ env
  end
end

@doc """
Evaluation functions of expressions, case clauses,
patter matching and sequences
"""
defmodule Eager do

  def eval_expr({:atm, id}, _) do {:ok, id} end

  def eval_expr({:var, id}, env) do
    case Env.lookup(id, env) do
      nil -> :error
      {_, str} -> {:ok, str}
    end
  end

  def eval_expr({:cons, head, tail}, env) do
    case eval_expr(head, env) do
      :error -> :error
      {:ok, id} ->
        case eval_expr(tail, env) do
          :error -> :error
          {:ok, ts} -> {:ok, {id,ts}}
        end
    end
  end

  def eval_expr({:lambda, par, free, seq}, env) do
    case Env.closure(free, env) do
      :error ->
        :error
      closure ->
        {:ok, {:closure, par, seq, closure}}
    end
  end

  def eval_expr({:apply, expr, args}, env) do
    case eval_expr(expr, env) do
      :error ->
        :error
      {:ok, {:closure, par, seq, closure}} ->
        case eval_args(args, env) do
          :error ->
            :foo
          strs ->
            env = Env.args(par, strs, closure)
            eval_seq(seq, env)
        end
    end
  end

  def eval_expr({:case, expr, cls}, env) do
    case eval_expr(expr, env) do
      :error -> :error
      {:ok, str} ->
        eval_cls(cls, str, env)
    end
  end

  def eval_match(:ignore, _, env) do
    {:ok, env}
  end

  def eval_match({:atm, id}, id, env) do
    {:ok,  env}
  end

  def eval_match({:var, id}, str, env) do
    case Env.lookup(id, env) do
      nil ->
        {:ok, Env.add(id,str,env)}
      {_, ^str} ->
        {:ok, env}
      {_, _} ->
        :fail
    end
  end

  def eval_match({:cons, hp, tp}, {s1,s2}, env) do
    case eval_match(hp, s1, env) do
      :fail -> :fail
      {:ok, env} ->
        eval_match(tp, s2, env)
    end
  end
  def eval_match(_, _, _) do
    :fail
  end

  def eval_seq([exp], env) do
    eval_expr(exp, env)
  end

  def eval_seq([{:match, pattern, exp} | rest], env) do
    case eval_expr(exp, env) do
      :error -> :error
      {:ok, name} ->
        vars = extract_vars(pattern)
        env = Env.remove(vars, env)

        case eval_match(pattern, name, env) do
          :fail ->
            :error
          {:ok, env} ->
            eval_seq(rest, env)
        end
    end
  end

  defp extract_vars(l) do extract_vars(l,[]) end

  defp extract_vars(:ignore,l1) do l1 end

  defp extract_vars({:atm,_},l1) do l1 end

  defp extract_vars({:var, var}, l1) do [var| l1] end

  defp extract_vars({:cons ,head,tail},l1) do extract_vars(tail, extract_vars(head,l1)) end

  def eval_args([], _) do [] end
  def eval_args([expr | exprs], env) do
    case eval_expr(expr, env) do
      :error -> :error
      {:ok, str} ->
        case eval_args(exprs, env) do
          :error -> :error
          strs -> [str | strs]
        end
    end
  end
  def eval(seq) do eval_seq(seq,[]) end

  def eval_cls([], _, _) do :error end
  def eval_cls([{:clause, ptr, seq} | cls], str, env) do
    vars = extract_vars(ptr)
    env  = Env.remove(vars, env)
    case eval_match(ptr,str,env) do
      :fail -> eval_cls(cls, str, env)
      {:ok, env} -> eval_seq(seq, env)
    end
  end


end
