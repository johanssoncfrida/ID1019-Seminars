#Du skall implementera en räknare som kan hantera rationella tal.
#Räknaren skall kunna hantera: addition, subtraktion och multiplikation.
#Svaret som räknaren ger skall vara på så enkel form som möjligt; några exempel:
#
#Du väljer själv hur uttryck och tal (heltal och rationella) skall representeras.
#Du får, förutom de aritmetiska operationerna, endast använda de inbyggda funktionerna:
#rem/2 , div/2 och abs/1. Som en hjälp på traven ges funktionen gcd/2 som returnerar den
#största gemensamma delaren för två heltal.
#

defmodule Exam do

  def add({:num,num1},{:num,num2}) do
    {:num, num1+num2}
  end

  def add({:rat,num1,den1},{:rat,num2,den2}) do
    den3 = gcd(den1,den2)
    newden = div((den1*den2),den3)
    newnum = (num1*div(newden,den1) + (num2*div(newden,den2)))
    {:rat, newnum, newden}
  end

  def add({:num,num1},{:rat,num2,den2}) do
    den1 = 1
    den3 = gcd(den1,den2)
    newden = div((den1*den2),den3)
    newnum = (num1*div(newden,den1) + (num2*div(newden,den2)))
    {:rat, newnum, newden}
  end

  def add({:rat,num1,den1},{:num,num2}) do
    den2 = 1
    den3 = gcd(den1,den2)
    newden = div((den1*den2),den3)
    newnum = (num1*div(newden,den1) + (num2*div(newden,den2)))
    {:rat, newnum, newden}
  end

  def sub({:num,num1},{:num,num2}) do
    {:num, num1-num2}
  end

  def sub({:num,num1},{:rat,num2,den2}) do
    den1 = 1
    den3 = gcd(den1,den2)
    newden = div((den1*den2),den3)
    newnum = (num1*div(newden,den1) - (num2*div(newden,den2)))
    {:rat, newnum, newden}
  end

  def sub({:rat,num1,den1},{:num,num2}) do
    den2 = 1
    den3 = gcd(den1,den2)
    newden = div((den1*den2),den3)
    newnum = (num1*div(newden,den1) - (num2*div(newden,den2)))
    {:rat, newnum, newden}
  end

  def sub({:rat,num1,den1},{:rat,num2,den2}) do
    den3 = gcd(den1,den2)
    newden = div((den1*den2),den3)
    newnum = (num1*div(newden,den1) - (num2*div(newden,den2)))
    {:rat, newnum, newden}
  end

  def mul({:num,num1},{:num,num2}) do
    {:num, num1*num2}
  end

  def mul({:num,num1},{:rat,num2,den2}) do
    newnum = num1*num2
    {:rat, newnum, den2}
  end

  def mul({:rat,num1,den1},{:num,num2}) do
    newnum = num1*num2
    {:rat, newnum, den1}
  end

  def mul({:rat,num1,den1},{:rat,num2,den2}) do
    newden = den1*den2
    newnum = num1*num2
    {:rat, newnum, newden}
  end

  def simplify({:num, _num}=newnum) do newnum end
  def simplify({:rat, num, den}) do
    common = gcd(num, den)
    newden = den/common
    newnum = num/common
    if newden == 1 do
      {:num, newnum}
    else
      {:rat, newnum, newden}
    end
  end

  def gcd(n,n) do n end
  def gcd(a,b) when a > b do gcd(a-b, b) end
  def gcd(a,b) do gcd(a, b-a) end

  def calc({:sub, a, b}) do sub( calc(a), calc(b)) end
  def calc({:mul, a, b}) do mul( calc(a), calc(b)) end
  def calc({:add, a, b}) do add( calc(a), calc(b)) end
  def calc( n ) do n end

  @doc """
  Param: {:add, {:rat,5,6},{:rat,1,6}}
  Param: {:mul, {:rat,5,6},{:num, 6}}
  Param: {:sub, {:rat,5,6},{:rat,1,6}}
  Param: {:add, {:rat,5,6},{:num, 1}}
  Param: {:add, {:mul,{:rat,4,3},{:rat,3,5}},{:add,{:mul,{:num,1},{:num,5}},{:rat,1,5}}}
  """
  def kalkylator(exp) do
    simplify(calc(exp))
  end

end
