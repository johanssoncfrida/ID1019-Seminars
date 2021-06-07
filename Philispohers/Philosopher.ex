defmodule Chopstick do
  def start() do
    stick = spawn_link(fn -> available() end)
  end

  def available() do
    receive do
      {:request, from} ->
        send(from, :granted)
        gone()
      :quit -> :ok
    end
  end


  def gone() do
    receive do
      :return -> available()
      :quit -> :ok
    end
  end

  # A philosopher requests stick
  def request(stick, ms) do
    send(stick, {:request, self()})
    receive do
      :granted -> :ok
    after
      ms -> :no
    end
  end

  # Return stick
  def return(stick) do
    send(stick, :return)
  end

  def quit(stick) do
    send(stick, :quit)
  end

end

defmodule Philosopher do

  @dream 1000
  @eat 50
  @delay 200
  @ms 200

  def start(hunger, right, left, name, ctrl) do
    philosopher = spawn_link(fn -> createPhilosopher(hunger, right, left, name, ctrl) end)
  end

  def createPhilosopher(hunger, right, left, name, ctrl) do
    dreaming(hunger, right, left, name, ctrl)
  end

  # Dreaming
  def dreaming(0, _, _, name, ctrl) do
    IO.puts("#{name} is done!")
    send(ctrl, :done)
  end

  def dreaming(hunger, right, left, name, ctrl) do
    IO.puts("#{name} is dreaming...")
    sleep(@dream)
    waiting(hunger, right, left, name, ctrl)
  end

  # Waiting for soomething
  def waiting(hunger, right, left, name, ctrl) do
    IO.puts("#{name} is waiting..")
    case Chopstick.request(left, @ms) do
      :ok ->
        case Chopstick.request(right, @ms) do
          :ok ->
            IO.puts("#{name} both sticks got picked!")
            eating(hunger, right, left, name, ctrl)
        end
    end
  end

  # Eating
  def eating(hunger, right, left, name, ctrl) do
    IO.puts("#{name} is eating.")
    sleep(@eat)
    Chopstick.return(left)
    Chopstick.return(right)
    dreaming(hunger - 1, right, left, name, ctrl)
  end

  def sleep(0) do :ok end
  def sleep(t) do
    :timer.sleep(:rand.uniform(t))
  end

end

defmodule Dinner do
  def start() do spawn(fn -> init() end) end

  def init() do
    c1 = Chopstick.start()
    c2 = Chopstick.start()
    c3 = Chopstick.start()
    c4 = Chopstick.start()
    c5 = Chopstick.start()
    ctrl = self()
    Philosopher.start(5, c1, c2, "Arendt", ctrl)
    Philosopher.start(5, c2, c3, "Hypatia", ctrl)
    Philosopher.start(5, c3, c4, "Simone", ctrl)
    Philosopher.start(5, c4, c5, "Elisabeth", ctrl)
    Philosopher.start(5, c5, c1, "Ayn", ctrl)
    wait(5, [c1, c2, c3, c4, c5])
  end

  def wait(0, chopsticks) do
    Enum.each(chopsticks, fn(c) -> Chopstick.quit(c) end)
  end
  def wait(n, chopsticks) do
    receive do
      :done ->
        wait(n - 1, chopsticks)
      :abort ->
        Process.exit(self(), :kill)
    end
  end

end
