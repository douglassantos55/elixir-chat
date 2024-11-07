defmodule ChatServer.Command.Processor do
  alias ChatServer.Command.Commands

  def process({:help, command}, state) do
    {state, "\r\n" <> Commands.help(command) <> "\r\n"}
  end

  def process({:connect, username}, state) do
    case Registry.register(ChatServer.UserRegistry, username, nil) do
      {:ok, _} -> {Map.put(state, :name, username), "Welcome #{username}!\r\n"}
      {:error, _} -> {state, "Username already taken. Please choose another username.\r\n"}
    end
  end

  def process({:create, room_name}, state) do
    with {:ok, username} <- ensure_connected(state) do
      case ChatServer.Room.Supervisor.create_room(room_name, username) do
        {:ok, _} -> {state, "Room created.\r\n"}
        {:error, _} -> {state, "Room already exists. Choose another name for your room.\r\n"}
      end
    end
  end

  def process({:join, room_name}, state) do
    with {:ok, username} <- ensure_connected(state) do
      case ChatServer.Room.Registry.whereis_name(room_name) do
        :undefined ->
          {state, "Room not found.\r\n"}

        pid ->
          case ChatServer.Room.join(pid, username) do
            :ok -> {state, "Joined \"#{room_name}\".\r\n"}
            :already_joined -> {state, "You've already joined \"#{room_name}\".\r\n"}
          end
      end
    end
  end

  def process({:leave, room_name}, state) do
    with {:ok, username} <- ensure_connected(state) do
      case ChatServer.Room.Registry.whereis_name(room_name) do
        :undefined ->
          {state, "Room not found.\r\n"}

        pid ->
          case ChatServer.Room.leave(pid, username) do
            :ok -> {state, "Left \"#{room_name}\".\r\n"}
            :not_joined -> {state, "You've not joined \"#{room_name}\".\r\n"}
          end
      end
    end
  end

  def process({:delete, room_name}, state) do
    with {:ok, username} <- ensure_connected(state) do
      case ChatServer.Room.Registry.whereis_name(room_name) do
        :undefined ->
          {state, "Room not found.\r\n"}

        room_pid ->
          case ChatServer.Room.owner?(room_pid, username) do
            true ->
              ChatServer.Room.Registry.unregister_name(room_name)
              {state, "Room deleted.\r\n"}

            false ->
              {state, "You do not own this room.\r\n"}
          end
      end
    end
  end

  def process({:message, room, message}, state) do
    with {:ok, username} <- ensure_connected(state) do
      case ChatServer.Room.Registry.whereis_name(room) do
        :undefined ->
          {state, "Room not found.\r\n"}

        room_pid ->
          case ChatServer.Room.joined?(room_pid, username) do
            true ->
              received = ChatServer.Room.broadcast(room_pid, username, message)
              {state, received}

            false ->
              {state, "You must join the room before sending messages. See /help join.\r\n"}
          end
      end
    end
  end

  def process({:error, reason}, state) do
    message =
      case reason do
        :invalid_argument ->
          "Invalid argument. Type /help for more information on each command.\r\n"

        _ ->
          "Something went horribly wrong.\r\n"
      end

    {state, message}
  end

  defp ensure_connected(state) do
    case Map.get(state, :name) do
      nil ->
        {state, "You must be connected before performing this action. See /help connect.\r\n"}

      username ->
        {:ok, username}
    end
  end
end
