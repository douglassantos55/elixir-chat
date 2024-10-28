defmodule ChatServer.Command.Processor do
  def process({:connect, username}, state) do
    case Registry.register(ChatServer.UserRegistry, username, nil) do
      {:ok, _} -> {Map.put(state, :name, username), "Welcome #{username}!\r\n"}
      {:error, _} -> {state, "Username already taken. Please choose another username.\r\n"}
    end
  end
end
