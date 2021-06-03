defmodule CRC do

  @doc """
  CRC (Cyclic Redundancy Check),  är en ceck-summa som man använder inom datakommunikation
  för att upptäcka eventuella felaktigheter i överförd data. Algoritmen lämpar sig mycket
  bra att implementera i hårdvara men din uppgift är att implementera den i Elixir.

  Vi antar att vi har en sekvens av bitar representerade som en lista av ettor och nollor.
  Normalt så används CRC-koder av längd 32 bitar men vi gör det enkelt för oss och räknar
  bara med koder av längd tre bitar. För detta krävs en  fyrbitars "generator" som vi väljer
  att vara samma för alla uppgifter.

  En CRC-kod för en sekvens, som man förlängt med tre nollor, definieras enligt
  följande tre regler:

  1. Om sekvensen är tre bitar lång så är detta den beräknade koden.
  2. Om sekvensen börjar med en nolla så beräknas koden från resten av sekvensen.
  3. Koden för en sekvens är koden som fås från sekvensen där man tagit xor av sekvensens
     första fyra bitar och den generator som vi har.
  """

  def crc() do
    [1,1,0,1,0,0,1,1,1,0,1,1,0,0]
  end

  def run(l, generator) do
    list = l ++ [0,0,0]
    f = fn (a,b) -> a == b end
    check(list, f)
  end

  def xor([], _, _, _) do [] end
  def xor(l, _, 0, f) do l end
  def xor([hl|rest], [hg|tail] = gen, n, f) when n >= 1 do
    case f.(hl,hg) do
      true ->  [0|xor(rest,tail,n-1,f)]
      false -> [1|xor(rest,tail,n-1,f)]
      end
    end

  def check([], f) do [] end
  def check([h|t] = l, f) when h == 0 do check(t,f) end
  def check([h|t] = l, f) do
    case length(l) do
      3 -> l
      _ -> list = xor(l, [1,0,1,1], 4,f)
           check(list, f)
   end
  end

end
