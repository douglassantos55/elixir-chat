defmodule ChatServer.Command.TextParserTest do
  use ExUnit.Case
  alias ChatServer.Command.TextParser

  describe "/connect" do
    test "should error without name" do
      assert {:error, :invalid_argument} = TextParser.parse("/connect")
    end

    test "should error when empty name" do
      assert {:error, :invalid_argument} = TextParser.parse("/connect    ")
    end

    test "should replace any separator with dashes" do
      assert {:connect, "john-doe"} = TextParser.parse("/connect john doe")
      assert {:connect, "john-doe"} = TextParser.parse("/connect john_doe")
      assert {:connect, "john-doe"} = TextParser.parse("/connect john#doe")
      assert {:connect, "john-doe"} = TextParser.parse("/connect john%doe")
      assert {:connect, "john-doe"} = TextParser.parse("/connect john~doe")
      assert {:connect, "john-doe"} = TextParser.parse("/connect john$doe")
      assert {:connect, "john-doe"} = TextParser.parse("/connect john[doe")
      assert {:connect, "john-doe"} = TextParser.parse("/connect john]doe")
      assert {:connect, "john-doe"} = TextParser.parse("/connect john)doe")
      assert {:connect, "john-doe"} = TextParser.parse("/connect john(doe")
      assert {:connect, "john-doe"} = TextParser.parse("/connect john{doe")
      assert {:connect, "john-doe"} = TextParser.parse("/connect john}doe")
      assert {:connect, "john-doe"} = TextParser.parse("/connect john=doe")
      assert {:connect, "john-doe"} = TextParser.parse("/connect john*doe")
      assert {:connect, "john-doe"} = TextParser.parse("/connect john+doe")
      assert {:connect, "john-doe"} = TextParser.parse("/connect john!doe")
      assert {:connect, "john-doe"} = TextParser.parse("/connect john@doe")
      assert {:connect, "john-doe"} = TextParser.parse("/connect john/doe")
      assert {:connect, "john-doe"} = TextParser.parse("/connect john\\doe")
      assert {:connect, "john-doe"} = TextParser.parse("/connect john'doe")
    end

    test "should trim invalid wrappers" do
      assert {:connect, "john-doe"} = TextParser.parse("/connect john doe")
      assert {:connect, "john-doe"} = TextParser.parse("/connect (john doe)")
      assert {:connect, "john-doe"} = TextParser.parse("/connect [john doe]")
      assert {:connect, "john-doe"} = TextParser.parse("/connect *john doe*")
      assert {:connect, "john-doe"} = TextParser.parse("/connect _john-doe_")
      assert {:connect, "john-doe"} = TextParser.parse("/connect -john-doe-")
      assert {:connect, "xjohn-doex"} = TextParser.parse("/connect xjohn-doex")
    end
  end
end
