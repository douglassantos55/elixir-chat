defmodule ChatServer.Command.Processor do
  alias ChatServer.Command.Commands

  def process({:help, command}, state) do
    {state, "\r\n" <> Commands.help(command) <> "\r\n"}
  end

  def process({:create, room_name}, state) do
    with :ok <- ensure_connected(state) do
      case Registry.register(ChatServer.RoomRegistry, room_name, nil) do
        {:ok, _} -> {state, "Room created.\r\n"}
        {:error, _} -> {state, "Room already exists. Choose another name for your room.\r\n"}
      end
    end
  end

  def process({:connect, username}, state) do
    case Registry.register(ChatServer.UserRegistry, username, nil) do
      {:ok, _} -> {Map.put(state, :name, username), "Welcome #{username}!\r\n"}
      {:error, _} -> {state, "Username already taken. Please choose another username.\r\n"}
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
      nil -> {state, "You must be connected before creating rooms. See /help connect.\r\n"}
      _ -> :ok
    end
  end
end
