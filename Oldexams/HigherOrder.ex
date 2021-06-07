defmodule Higher do
@doc """
Implementera en funktion som tar: en lista, ett initialt värde och
en funktion. Funktionen skall returnera en lista av de första
elementen i listan där funktioen som ges som argument bestämmer hur
många element som skall tas med.

Den funktion som ges som argument skall ta två argument:
ett element från listan och ett ackumulerat värde.
Funktionen skall returnera, antingen:

{:ok, acc} : om elementet skall vara med, acc är det nya ackumulerade
värdet och vi ska fortsätta, eller :no : om vi skall sluta traversera listan.
(acc kan användas för att avgöra om vi skall fortsätta)
"""
  def run([h|t],init, f) do
    case f.(h,init) do
      {:ok, acc} -> [h| run(t, acc, f)]
      :no -> []
    end
  end

  def getFunction() do
    f = fn(x, acc) -> if x < acc do
      newacc = acc - x
      {:ok, newacc}
    else :no
    end
  end
end
end
