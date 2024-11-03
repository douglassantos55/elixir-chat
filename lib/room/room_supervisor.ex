defmodule ChatServer.Room.Supervisor do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def create_room(room_name, owner) do
    DynamicSupervisor.start_child(__MODULE__, {ChatServer.Room, [room_name, owner]})
  end
end
