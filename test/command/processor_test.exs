defmodule ChatServer.Command.ProcessorTest do
  use ExUnit.Case
  alias ChatServer.Command.Processor

  describe "help" do
    test "should list all available commands" do
      assert {nil,
              "\r\nAvailable commands:\r\n\r\n/rooms\t\t\t\tList all rooms created.\r\n/users\t\t\t\tList all connected users.\r\n/connect [username]\t\tAuthenticates using the given username.\r\n/create [room-name]\t\tCreates a room with the given name.\r\n/delete [room-name]\t\tDeletes a created room. You must be the one who created the room.\r\n/join [room-name]\t\tJoin an existing room. You'll be able to receive and send messages in this room.\r\n/leave [room-name]\t\tLeave a room. You'll not be able to receive or send messages to this room.\r\n/message [room-name] [message]\tSends the given message to the informed room.\r\n/private [username] [message]\tSends a private message to the given username.\r\n\r\n"} =
               Processor.process({:help, "all"}, nil)
    end

    test "should show information about given command" do
      assert {nil, "\r\n/connect [username]\t\tAuthenticates using the given username.\r\n\r\n"} =
               Processor.process({:help, "connect"}, nil)
    end

    test "should return error when command does not exist" do
      assert {nil, "\r\nInvalid command. Use /help to list the available commands.\r\n\r\n"} =
               Processor.process({:help, "download"}, nil)
    end
  end

  describe "create" do
    setup do
      start_supervised!({ChatServer.Room.Registry, nil})
      start_supervised!({ChatServer.Room.Supervisor, nil})
      :ok
    end

    test "should start a process" do
      assert {%{}, "Room created.\r\n"} =
               Processor.process({:create, "room-name"}, %{name: "john-doe"})

      refute :undefined == ChatServer.Room.Registry.whereis_name("room-name")
    end

    test "should join created room" do
      assert {%{}, "Room created.\r\n"} =
               Processor.process({:create, "room-name"}, %{name: "john-doe"})

      assert ["john-doe"] = ChatServer.Room.list_users("room-name")
    end

    test "should not create room when name already registered" do
      assert {%{}, "Room created.\r\n"} =
               Processor.process({:create, "room-name"}, %{name: "john-doe"})

      assert {%{}, "Room already exists. Choose another name for your room.\r\n"} =
               Processor.process({:create, "room-name"}, %{name: "john-doe"})

      assert :undefined != ChatServer.Room.Registry.whereis_name("room-name")
    end

    test "should be able to create many rooms" do
      assert {%{}, "Room created.\r\n"} =
               Processor.process({:create, "lobby"}, %{name: "john-doe"})

      assert {%{}, "Room created.\r\n"} =
               Processor.process({:create, "games"}, %{name: "john-doe"})

      assert :undefined != ChatServer.Room.Registry.whereis_name("lobby")
      assert :undefined != ChatServer.Room.Registry.whereis_name("games")
    end

    test "should not be able to create without being connected" do
      assert {%{}, "You must be connected before performing this action. See /help connect.\r\n"} =
               Processor.process({:create, "room-name"}, %{})

      assert :undefined == ChatServer.Room.Registry.whereis_name("room-name")
    end
  end

  describe "delete" do
    setup do
      start_supervised!({ChatServer.Room.Registry, nil})
      start_supervised!({ChatServer.Room.Supervisor, nil})
      :ok
    end

    test "should not be able to delete without being connected" do
      {%{}, "You must be connected before performing this action. See /help connect.\r\n"} =
        Processor.process({:delete, "room"}, %{})
    end

    test "should not be able to delete rooms created by other users" do
      assert {%{}, "Room created.\r\n"} =
               Processor.process({:create, "lobby"}, %{name: "jane-doe"})

      {%{}, "You do not own this room.\r\n"} =
        Processor.process({:delete, "lobby"}, %{name: "john-doe"})
    end

    test "should not be able to delete rooms that don't exist" do
      {%{}, "Room not found.\r\n"} =
        Processor.process({:delete, "lobby"}, %{name: "john-doe"})
    end

    test "should be able to delete rooms created by yourself" do
      assert {%{}, "Room created.\r\n"} =
               Processor.process({:create, "lobby"}, %{name: "john-doe"})

      {%{}, "Room deleted.\r\n"} =
        Processor.process({:delete, "lobby"}, %{name: "john-doe"})
    end
  end

  describe "join" do
    setup do
      start_supervised!({ChatServer.Room.Registry, nil})
      start_supervised!({ChatServer.Room.Supervisor, nil})
      start_supervised!({Registry, keys: :unique, name: ChatServer.UserRegistry})
      :ok
    end

    test "should not be able to join without being connected" do
      ChatServer.Room.Supervisor.create_room("lobby", "john")

      assert {%{}, "You must be connected before performing this action. See /help connect.\r\n"} =
               Processor.process({:join, "lobby"}, %{})
    end

    test "should not be able to join rooms that don't exist" do
      assert {%{}, "Room not found.\r\n"} =
               Processor.process({:join, "lobby"}, %{name: "john-doe"})
    end

    test "should be able to join multiple rooms" do
      ChatServer.Room.Supervisor.create_room("lobby", "john")
      ChatServer.Room.Supervisor.create_room("games", "john")

      assert {%{}, "Joined \"lobby\".\r\n"} = Processor.process({:join, "lobby"}, %{name: "jane"})
      assert {%{}, "Joined \"games\".\r\n"} = Processor.process({:join, "games"}, %{name: "jane"})

      assert ["john", "jane"] = ChatServer.Room.list_users("lobby")
      assert ["john", "jane"] = ChatServer.Room.list_users("games")
    end

    test "should error when already joined" do
      ChatServer.Room.Supervisor.create_room("lobby", "john")
      assert {%{}, "Joined \"lobby\".\r\n"} = Processor.process({:join, "lobby"}, %{name: "jane"})

      assert {%{}, "You've already joined \"lobby\".\r\n"} =
               Processor.process({:join, "lobby"}, %{name: "jane"})
    end
  end

  describe "leave" do
    setup do
      start_supervised!({ChatServer.Room.Registry, nil})
      start_supervised!({ChatServer.Room.Supervisor, nil})
      start_supervised!({Registry, keys: :unique, name: ChatServer.UserRegistry})
      :ok
    end

    test "should not be able to leave if not connected" do
      assert {%{}, "You must be connected before performing this action. See /help connect.\r\n"} =
               Processor.process({:leave, "lobby"}, %{})
    end

    test "should not be able to leave a room that does not exist" do
      assert {%{}, "Room not found.\r\n"} =
               Processor.process({:leave, "lobby"}, %{name: "john"})
    end

    test "should not be able to leave a room that you've not joined" do
      ChatServer.Room.Supervisor.create_room("lobby", "jane")

      assert {%{}, "You've not joined \"lobby\".\r\n"} =
               Processor.process({:leave, "lobby"}, %{name: "john"})
    end

    test "should leave room" do
      ChatServer.Room.Supervisor.create_room("lobby", "jane")
      Processor.process({:join, "lobby"}, %{name: "john"})

      assert {%{}, "Left \"lobby\".\r\n"} =
               Processor.process({:leave, "lobby"}, %{name: "john"})

      assert ["jane"] = ChatServer.Room.list_users("lobby")
    end
  end

  describe "connect" do
    setup do
      start_supervised!({Registry, keys: :unique, name: ChatServer.UserRegistry})
      :ok
    end

    test "should update name in state" do
      assert {%{name: "john-doe"}, "Welcome john-doe!\r\n"} =
               Processor.process({:connect, "john-doe"}, %{name: "no-name"})
    end

    test "should return error when username already exists" do
      Processor.process({:connect, "john-doe"}, %{name: "no-name"})

      assert {%{name: "no-name"}, "Username already taken. Please choose another username.\r\n"} =
               Processor.process({:connect, "john-doe"}, %{name: "no-name"})
    end
  end

  describe "error" do
    test "should return nice messages when errors occur" do
      assert {nil, "Invalid argument. Type /help for more information on each command.\r\n"} =
               Processor.process({:error, :invalid_argument}, nil)

      assert {nil, "Something went horribly wrong.\r\n"} =
               Processor.process({:error, :unexpected_error}, nil)
    end
  end

  describe "message" do
    setup do
      start_supervised!({ChatServer.Room.Registry, nil})
      start_supervised!({ChatServer.Room.Supervisor, nil})
      start_supervised!({Registry, keys: :unique, name: ChatServer.UserRegistry})
      :ok
    end

    test "should not be able to send messages if not connected" do
      assert {%{}, "You must be connected before performing this action. See /help connect.\r\n"} =
               Processor.process({:message, "lobby", "hi mom"}, %{})
    end

    test "should not be able to send messages to a room that does not exist" do
      assert {%{}, "Room not found.\r\n"} =
               Processor.process({:message, "lobby", "hello"}, %{name: "john"})
    end

    test "should not be able to send messages to a room which you've not joined" do
      ChatServer.Room.Supervisor.create_room("lobby", "john")

      assert {%{}, "You must join the room before sending messages. See /help join.\r\n"} =
               Processor.process({:message, "lobby", "hi people"}, %{name: "jane"})
    end

    test "should not be able to send messages to a room you've left" do
      ChatServer.Room.Supervisor.create_room("lobby", "john")
      Processor.process({:join, "lobby"}, %{name: "jane"})
      Processor.process({:leave, "lobby"}, %{name: "jane"})

      assert {%{}, "You must join the room before sending messages. See /help join.\r\n"} =
               Processor.process({:message, "lobby", "hi people"}, %{name: "jane"})
    end

    test "should be able to send messages to a joined room" do
      ChatServer.Room.Supervisor.create_room("lobby", "john")
      Processor.process({:join, "lobby"}, %{name: "jane"})

      assert {%{}, ["john"]} =
               Processor.process({:message, "lobby", "hi people"}, %{name: "jane"})
    end

    test "should send message to everyone connected to the room" do
      assert {:ok, _} = Registry.register(ChatServer.UserRegistry, "john", nil)
      assert {:ok, _} = Registry.register(ChatServer.UserRegistry, "jane", nil)
      assert {:ok, _} = Registry.register(ChatServer.UserRegistry, "james", nil)
      assert {:ok, _} = Registry.register(ChatServer.UserRegistry, "junior", nil)

      ChatServer.Room.Supervisor.create_room("lobby", "john")

      Processor.process({:join, "lobby"}, %{name: "jane"})
      Processor.process({:join, "lobby"}, %{name: "james"})
      Processor.process({:join, "lobby"}, %{name: "junior"})

      assert {%{}, ["john", "james", "junior"]} =
               Processor.process({:message, "lobby", "hello people!"}, %{name: "jane"})
    end
  end
end
