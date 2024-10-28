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

  describe "error" do
    test "should return nice messages when errors occur" do
      assert {nil, "Invalid argument. Type /help for more information on each command.\r\n"} =
               Processor.process({:error, :invalid_argument}, nil)

      assert {nil, "Something went horribly wrong.\r\n"} =
               Processor.process({:error, :unexpected_error}, nil)
    end
  end
end
