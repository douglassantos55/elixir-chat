defmodule ChatServer.Room do
  use GenServer, restart: :temporary

  def start_link([name, owner]) do
    GenServer.start_link(__MODULE__, owner, name: {:via, ChatServer.Room.Registry, name})
  end

  def init(owner) do
    {:ok, owner}
  end

  def owner?(name, username) when is_binary(name) do
    GenServer.call({:via, ChatServer.Room.Registry, name}, {:is_owner, username})
  end

  def owner?(pid, username) when is_pid(pid) do
    GenServer.call(pid, {:is_owner, username})
  end

  def handle_call({:is_owner, username}, _, state) do
    {:reply, state == username, state}
  end
end
