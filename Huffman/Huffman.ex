@doc """
Huffman Tree in Elixir
Seminar 1 in course ID1019
"""
defmodule Huffman do

   @doc """
    A sample text for testing purposes.
    """
    def sample do
      'the quick brown fox jumps over the lazy dog
      this is a sample text that we will use when we build
      up a table we will only handle lower case letters and
      no punctuation symbols the frequency will of course not
      represent english but it is probably not that far off'
  end

  def text do 'this is something we should encode' end

  @doc """
  Test the Huffman encoding
  """
  def test do
      sample = text()
      tree = tree(sample)
      encode = encode_table(tree)
      decode = encode_table(tree, [])
      text = text()
      seq = encode(text, encode)
      decode(seq, decode)
  end

  @doc """
  Create a character frequency tree from given text sample.
  """
  def tree(sample) do
    freqlist =isorttail(freq(sample))
    huffman_tree(freqlist)
  end

  @doc """
  Find a freqency list of given sample.
  """
  def freq(sample) do freq(sample, []) end
  def freq([], freq) do freq end
  def freq([char | rest], freq) do
      freq(rest, insertFreq(char, freq))
  end

  @doc """
  Insert a character into the frequency list, maintaining low to high ordering.
  """
  def insertFreq(char, []) do
    [{char, 1}] end
  def insertFreq(char, [{storedchar,storedfreq}|rest]) do
    if(char == storedchar) do
      [ {storedchar,storedfreq + 1}|rest ]
    else
      [{storedchar,storedfreq} | insertFreq(char,rest)]
    end
  end
  @doc """
  Sorting frequencylist in low to high ordering.
  """
  def isorttail(l) do isorttail(l, []) end
  def isorttail([], sofar) do sofar end
  def isorttail([h|t], sofar) do
    res = insert(h,sofar)
    isorttail(t,res)
  end

  def insert(elem,[]) do [elem] end
  def insert({char,freq} = elem, [{sortedchar,sortedfreq}|t]=l) do
     if sortedfreq < freq do
      [{sortedchar,sortedfreq} | insert(elem, t)]
    else
      [{char,freq} | l]
    end
  end

  @doc """
  Generate a Huffman tree from a character frequency list.
  """
  def huffman_tree([{tree, _}]) do tree end
  def huffman_tree([{a, af}, {b, bf} | rest]) do
    res=insert_in_tree({{a, b}, af + bf}, rest)
    huffman_tree(res)
  end

  def insert_in_tree({a, af}, []) do [{a, af}] end
  def insert_in_tree({a, af}, [{_b, bf} | _rest]= tree) when af < bf do
   [{a, af}|tree]
  end
  def insert_in_tree({a, af}, [{b, bf} | rest]) do
   [{b, bf} | insert_in_tree({a, af}, rest)]
  end

  @doc """
  Encode table and make path to characters, 0 for left and 1 for right
  """
  def encode_table(tree) do
    encode_table(tree, [])
  end
  def encode_table({left_branch, right_branch}, table) do
    left = encode_table(left_branch, [0 | table])
    right = encode_table(right_branch, [1 | table])
    left ++ right
  end
  def encode_table(node, table) do
    [{node, reverse(table)}]
  end

  def reverse(list) do reverse(list,[]) end
  def reverse([], reversed) do reversed end
  def reverse([h|t], reversed) do
    reverse(t,[h|reversed])
  end
  @doc """
  Receives a list of tuples and returns a list of bits
  corresponding to the characters in the table
  """
  def encode([], _) do [] end
  def encode([head|tail], table) do
    case lookup(head,table) do
        {:found, code} -> code ++ encode(tail, table)
        {:notfound, msg} -> msg
    end
  end

  def lookup(head, [{head,code}|_rest]) do {:found, code} end
  def lookup(head, [{_fc,_code}|rest]) do lookup(head, rest) end
  def lookup(_, _) do {:notfound, "The character is not found in this encoding table"} end

  @doc """
  Decodes a sequence of bits from a Huffman tree
  """
  def decode([], _) do [] end
  def decode(seq, table) do
    {char, rest} = decode_char(seq, 1, table)
    [char | decode(rest, table)]
  end

  def decode_char(seq, n, table) do
    {code, rest} = Enum.split(seq, n)
    case List.keyfind(table, code, 1) do
        {char, bitseq} -> {char, rest}
        nil -> decode_char(seq, n+1,table)
    end
  end
end
