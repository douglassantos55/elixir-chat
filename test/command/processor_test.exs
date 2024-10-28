defmodule ChatServer.Command.ProcessorTest do
  use ExUnit.Case
  alias ChatServer.Command.Processor

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
end
