defmodule ChatServer.Room.RoomTest do
  use ExUnit.Case

  describe "Room" do
    test "should remove crashed user processes" do
      start_supervised!({ChatServer.Room.Registry, []})
      start_supervised!({Registry, keys: :unique, name: ChatServer.UserRegistry})

      user_pid = start_supervised!({ChatServer.User, "jane"})
      {:ok, room_pid} = ChatServer.Room.start_link(["lobby", "john"])

      assert :ok = ChatServer.Room.join(room_pid, "jane")
      assert ["john", "jane"] = ChatServer.Room.list_users("lobby")

      Process.exit(user_pid, :kill)
      assert ["john"] = ChatServer.Room.list_users("lobby")
    end
  end
end
