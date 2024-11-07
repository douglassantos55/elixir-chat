defmodule ChatServer do
  def init(port) do
    {:ok, listen_socket} =
      :gen_tcp.listen(port, [:binary, active: true, packet: :line, reuseaddr: true])

    loop_acceptor(listen_socket)
  end

  def loop_acceptor(listen_socket) do
    {:ok, socket} = :gen_tcp.accept(listen_socket)

    case :inet.peername(socket) do
      {:ok, {ip_address, _}} ->
        {:ok, pid} = ChatServer.User.start(ip_address, socket)
        :gen_tcp.controlling_process(socket, pid)

      {:error, _} ->
        :gen_tcp.close(socket)
    end

    loop_acceptor(listen_socket)
  end
end
