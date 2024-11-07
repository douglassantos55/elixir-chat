defmodule ChatServer.Room do
  require Logger
  use GenServer, restart: :temporary

  def start_link([name, owner]) do
    GenServer.start_link(__MODULE__, {owner, name}, name: {:via, ChatServer.Room.Registry, name})
  end

  def init({owner, name}) do
    {:ok, {owner, name, %{}}}
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

  def joined?(pid, username) when is_pid(pid) do
    GenServer.call(pid, {:joined, username})
  end

  def owner?(pid, username) when is_pid(pid) do
    GenServer.call(pid, {:is_owner, username})
  end

  def broadcast(pid, sender, message) when is_pid(pid) do
    GenServer.call(pid, {:broadcast, sender, message})
  end

  def handle_call({:join, username}, _, {owner, name, users} = state) do
    case Map.has_key?(users, username) do
      true ->
        {:reply, :already_joined, state}

      false ->
        user_pid = monitor_user(username)
        new_users = Map.put(users, username, user_pid)
        {:reply, :ok, {owner, name, new_users}}
    end
  end

  def handle_call({:leave, username}, _, {owner, name, users}) do
    {response, new_users} =
      case Map.has_key?(users, username) do
        true -> {:ok, Map.delete(users, username)}
        false -> {:not_joined, users}
      end

    {:reply, response, {owner, name, new_users}}
  end

  def handle_call({:is_owner, username}, _, {owner, _, _} = state) do
    {:reply, owner == username, state}
  end

  def handle_call({:joined, username}, _, {owner, _, users} = state) do
    {:reply, owner == username || Map.has_key?(users, username), state}
  end

  def handle_call({:list_users}, _, {owner, _, users} = state) do
    {:reply, [owner | Map.keys(users)], state}
  end

  def handle_call({:broadcast, sender, message}, _, {owner, name, users} = state) do
    timestamp = DateTime.to_string(DateTime.utc_now(:second))
    formatted_message = "[" <> timestamp <> "] " <> name <> " / " <> sender <> ": " <> message

    received =
      for user when user != sender <- [owner | Map.keys(users)] do
        ChatServer.User.send(user, formatted_message)
        user
      end

    {:reply, received, state}
  end

  def handle_info({:DOWN, _, :process, pid, _}, {owner, name, users}) do
    {:noreply, {owner, name, Map.reject(users, fn {_, v} -> v == pid end)}}
  end

  defp monitor_user(username) do
    case Registry.lookup(ChatServer.UserRegistry, username) do
      [{user_pid, _}] ->
        Process.monitor(user_pid)
        user_pid

      [] ->
        nil
    end
  end
end
