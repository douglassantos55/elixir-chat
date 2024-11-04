defmodule ChatServer.Room do
  use GenServer, restart: :temporary

  def start_link([name, owner]) do
    GenServer.start_link(__MODULE__, owner, name: {:via, ChatServer.Room.Registry, name})
  end

  def init(owner) do
    {:ok, {owner, []}}
  end

  def list_users(name) do
    GenServer.call({:via, ChatServer.Room.Registry, name}, {:list_users})
  end

  def join(pid, username) when is_pid(pid) do
    GenServer.call(pid, {:join, username})
  end

  def leave(pid, username) when is_pid(pid) do
    GenServer.call(pid, {:leave, username})
  end

  def owner?(name, username) when is_binary(name) do
    GenServer.call({:via, ChatServer.Room.Registry, name}, {:is_owner, username})
  end

  def owner?(pid, username) when is_pid(pid) do
    GenServer.call(pid, {:is_owner, username})
  end

  def handle_call({:join, username}, _, {owner, users} = state) do
    case Enum.any?(users, &(&1 == username)) do
      true -> {:reply, :already_joined, state}
      false -> {:reply, :ok, {owner, [username | users]}}
    end
  end

  def handle_call({:leave, username}, _, {_, users} = state) do
    new_users = List.delete(users, username)
    result = if length(new_users) < length(users), do: :ok, else: :not_joined
    {:reply, result, state}
  end

  def handle_call({:is_owner, username}, _, {owner, _} = state) do
    {:reply, owner == username, state}
  end

  def handle_call({:list_users}, _, {owner, users} = state) do
    {:reply, [owner | users], state}
  end
end
