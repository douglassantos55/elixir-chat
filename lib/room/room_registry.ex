defmodule ChatServer.Room.Registry do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, %{}}
  end

  def list_rooms() do
    GenServer.call(__MODULE__, {:list})
  end

  def register_name(name, pid) do
    GenServer.call(__MODULE__, {:register, name, pid})
  end

  def unregister_name(name) do
    GenServer.call(__MODULE__, {:unregister, name})
  end

  def whereis_name(name) do
    GenServer.call(__MODULE__, {:whereis, name})
  end

  def send(name, message) do
    Kernel.send(whereis_name(name), message)
  end

  def handle_call({:list}, _, state) do
    {:reply, Map.keys(state), state}
  end

  def handle_call({:register, name, pid}, _, state) do
    case Map.get(state, name) do
      nil ->
        Process.monitor(pid)
        {:reply, :yes, Map.put(state, name, pid)}

      _ ->
        {:reply, :no, state}
    end
  end

  def handle_call({:unregister, name}, _, state) do
    Process.exit(Map.get(state, name), :kill)
    {:reply, :ok, Map.delete(state, name)}
  end

  def handle_call({:whereis, name}, _, state) do
    {:reply, Map.get(state, name, :undefined), state}
  end

  def handle_info({:DOWN, _, :process, pid, _}, state) do
    {:noreply, Map.reject(state, fn {_, v} -> v == pid end)}
  end
end
