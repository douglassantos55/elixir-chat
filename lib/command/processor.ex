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
end
