defmodule ChatServer.Application do
  def start(_type, _args) do
    children = [
      {ChatServer.Room.Registry, []},
      {ChatServer.Room.Supervisor, []},
      {Registry, keys: :unique, name: ChatServer.UserRegistry},
      %{
        id: ChatServer.Server,
        start: {ChatServer.Server, :start_link, [8080]}
      }
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: ChatServer.Supervisor)
  end
end
