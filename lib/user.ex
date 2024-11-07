defmodule ChatServer.User do
  require Logger
  use GenServer

  def start_link(username) do
    GenServer.start_link(
      __MODULE__,
      %{name: username, ip: "127.0.0.1", socket: nil},
      name: {:via, Registry, {ChatServer.UserRegistry, username}}
    )
  end

  def start(ip_address, socket) do
    Logger.debug("new connection #{inspect(ip_address)}")

    GenServer.start(__MODULE__, %{
      name: "no-name",
      ip: ip_address,
      socket: socket
    })
  end

  def init(init_arg), do: {:ok, init_arg}

  def send(username, message) do
    GenServer.cast({:via, Registry, {ChatServer.UserRegistry, username}}, {:send, message})
  end

  def handle_cast({:send, message}, state) do
    case :gen_tcp.send(state.socket, message) do
      :ok -> :ok
      {:error, reason} -> Logger.error("could not send message to socket: #{inspect(reason)}")
    end

    {:noreply, state}
  end

  def handle_info({:tcp, socket, command}, state) do
    Logger.debug("new message received: #{command}")

    {new_state, response} =
      command
      |> ChatServer.Command.TextParser.parse()
      |> ChatServer.Command.Processor.process(state)

    Logger.debug("new_state: #{inspect(new_state)}")
    Logger.debug("response: #{inspect(response)}")

    if is_binary(response) do
      :gen_tcp.send(socket, response)
    end

    {:noreply, new_state}
  end

  def handle_info({:tcp_closed, _}, %{name: username}) do
    Logger.debug("socket connect closed, killing process #{inspect(self())}")
    Registry.unregister(ChatServer.UserRegistry, username)
    {:stop, :normal, []}
  end
end
