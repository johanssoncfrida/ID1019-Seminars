defmodule Emulator do
  @doc """
  Du skall implementera en emulator som kan exekvera ett assemblerprogram
  skrivet i ett väldigt begränsat språk. Den processor du skall emulera har
  ett tillstånd som kan beskrivas med: ett kodsegment, en programräknare och
  sex register (0..5). Det finns inget minne och kodsegmentet kan bara läsas.

  Emulatorn initieras med programräknaren satt till noll (den första instruktionen)
  och stegar sig framåt en instruktion i taget om inte programräknaren sätts om av
  en branch-instruktion.

  De instruktioner som emulatorn skall klara listas nedan. I psedukoden så betyder
  reg[x] till höger värdet i register x medan det till vänster i en tilldelning betyder
  att värdet skall skrivas till register x. Värden som blir ut-data (output) skall
  returneras i en lista ordnad med det första ut-värdet först.

  add d s1 s2        :  reg[d] := reg[s1] + reg[s2]
  addi d s1 imm      :  reg[d] := reg[s1] + imm
  beq s1 s2 offset   : pc := pc + offset if reg[s1] == reg[s2]
  out s1             : output reg[s1]
  halt               : terminate

  addi  1  0 10
  addi  3  0  1
  out   3
  addi  1  1 -1
  addi  4  3  0
  add   3  2  3
  out   3
  beq   1  0  3
  addi  2  4  0
  beq   0  0 -6
  halt
  """


  def addi({dest, s1, imm}, {{:counter, counter}, {:reg, reg}, output} = env) do
    sum = elem(reg, s1) + imm
    {{:counter, counter+1}, {:reg, put_elem(reg, dest, sum)}, output}
  end

  def add({dest, s1, s2}, {{:counter, counter}, {:reg, reg}, output} = env) do
    sum = elem(reg, s1) + elem(reg,s2)
    {{:counter, counter+1}, {:reg, put_elem(reg, dest, sum)}, output}
  end

  def out({s1}, {{:counter, counter}, {:reg, reg}, {:output, output}} = env) do
    newOutput = output ++ [elem(reg, s1)]
    {{:counter, counter + 1}, {:reg, reg}, {:output, newOutput}}
  end

  def beq({s1,s2,offset}, {{:counter, counter}, {:reg, reg}, output} = env) when elem(reg,s1) == elem(reg,s2) do
    {{:counter, counter + offset}, {:reg, reg}, output}
  end

  def beq({s1,s2,offset}, {{:counter, counter}, {:reg, reg}, output} = env) do
    {{:counter, counter + 1}, {:reg, reg}, output}
  end

  def test() do
    env = {{:counter,0}, {:reg, {0,0,0,0,0}}, {:output, []}}
  end

  def run(seq, {{:counter, counter},_,out} = env) do
    {type, info} = elem(seq, counter)
    case type do
      :addi -> newEnv = addi(info, env)
               run(seq, newEnv)
      :add -> newEnv = add(info, env)
              run(seq, newEnv)
      :beq -> newEnv = beq(info, env)
              run(seq, newEnv)
      :out -> newEnv = out(info, env)
              run(seq, newEnv)
      :halt -> out
    end
  end

end
