defmodule ChatServer.Command.TextParserTest do
  use ExUnit.Case
  alias ChatServer.Command.TextParser

  describe "/help" do
    test "should error when more than one argument" do
      assert {:error, :invalid_argument} = TextParser.parse("/help connect circuit")
    end

    test "should be valid without any arguments" do
      assert {:help, "all"} = TextParser.parse("/help")
      assert {:help, "all"} = TextParser.parse("/help ")
      assert {:help, "all"} = TextParser.parse("/help  ")
      assert {:help, "all"} = TextParser.parse("/help\n")
      assert {:help, "all"} = TextParser.parse("/help\r\n")
    end
  end

  describe "/create" do
    test "should error without room name" do
      assert {:error, :invalid_argument} = TextParser.parse("/create")
      assert {:error, :invalid_argument} = TextParser.parse("/create  ")
    end

    test "should replace any separator with dashes" do
      assert {:create, "john-doe"} = TextParser.parse("/create john doe")
      assert {:create, "john-doe"} = TextParser.parse("/create john_doe")
      assert {:create, "john-doe"} = TextParser.parse("/create john#doe")
      assert {:create, "john-doe"} = TextParser.parse("/create john%doe")
      assert {:create, "john-doe"} = TextParser.parse("/create john~doe")
      assert {:create, "john-doe"} = TextParser.parse("/create john$doe")
      assert {:create, "john-doe"} = TextParser.parse("/create john[doe")
      assert {:create, "john-doe"} = TextParser.parse("/create john]doe")
      assert {:create, "john-doe"} = TextParser.parse("/create john)doe")
      assert {:create, "john-doe"} = TextParser.parse("/create john(doe")
      assert {:create, "john-doe"} = TextParser.parse("/create john{doe")
      assert {:create, "john-doe"} = TextParser.parse("/create john}doe")
      assert {:create, "john-doe"} = TextParser.parse("/create john=doe")
      assert {:create, "john-doe"} = TextParser.parse("/create john*doe")
      assert {:create, "john-doe"} = TextParser.parse("/create john+doe")
      assert {:create, "john-doe"} = TextParser.parse("/create john!doe")
      assert {:create, "john-doe"} = TextParser.parse("/create john@doe")
      assert {:create, "john-doe"} = TextParser.parse("/create john/doe")
      assert {:create, "john-doe"} = TextParser.parse("/create john\\doe")
      assert {:create, "john-doe"} = TextParser.parse("/create john'doe")
    end
  end

  describe "delete" do
    test "should error without room name" do
      assert {:error, :invalid_argument} = TextParser.parse("/delete")
      assert {:error, :invalid_argument} = TextParser.parse("/delete ")
    end

    test "should replace any separator with dashes" do
      assert {:delete, "john-doe"} = TextParser.parse("/delete john doe")
      assert {:delete, "john-doe"} = TextParser.parse("/delete john_doe")
      assert {:delete, "john-doe"} = TextParser.parse("/delete john#doe")
      assert {:delete, "john-doe"} = TextParser.parse("/delete john%doe")
      assert {:delete, "john-doe"} = TextParser.parse("/delete john~doe")
      assert {:delete, "john-doe"} = TextParser.parse("/delete john$doe")
      assert {:delete, "john-doe"} = TextParser.parse("/delete john[doe")
      assert {:delete, "john-doe"} = TextParser.parse("/delete john]doe")
      assert {:delete, "john-doe"} = TextParser.parse("/delete john)doe")
      assert {:delete, "john-doe"} = TextParser.parse("/delete john(doe")
      assert {:delete, "john-doe"} = TextParser.parse("/delete john{doe")
      assert {:delete, "john-doe"} = TextParser.parse("/delete john}doe")
      assert {:delete, "john-doe"} = TextParser.parse("/delete john=doe")
      assert {:delete, "john-doe"} = TextParser.parse("/delete john*doe")
      assert {:delete, "john-doe"} = TextParser.parse("/delete john+doe")
      assert {:delete, "john-doe"} = TextParser.parse("/delete john!doe")
      assert {:delete, "john-doe"} = TextParser.parse("/delete john@doe")
      assert {:delete, "john-doe"} = TextParser.parse("/delete john/doe")
      assert {:delete, "john-doe"} = TextParser.parse("/delete john\\doe")
      assert {:delete, "john-doe"} = TextParser.parse("/delete john'doe")
    end
  end

  describe "/join" do
    test "should error without room name" do
      assert {:error, :invalid_argument} = TextParser.parse("/join")
      assert {:error, :invalid_argument} = TextParser.parse("/join ")
    end

    test "should replace any separator with dashes" do
      assert {:join, "john-doe"} = TextParser.parse("/join john doe")
      assert {:join, "john-doe"} = TextParser.parse("/join john_doe")
      assert {:join, "john-doe"} = TextParser.parse("/join john#doe")
      assert {:join, "john-doe"} = TextParser.parse("/join john%doe")
      assert {:join, "john-doe"} = TextParser.parse("/join john~doe")
      assert {:join, "john-doe"} = TextParser.parse("/join john$doe")
      assert {:join, "john-doe"} = TextParser.parse("/join john[doe")
      assert {:join, "john-doe"} = TextParser.parse("/join john]doe")
      assert {:join, "john-doe"} = TextParser.parse("/join john)doe")
      assert {:join, "john-doe"} = TextParser.parse("/join john(doe")
      assert {:join, "john-doe"} = TextParser.parse("/join john{doe")
      assert {:join, "john-doe"} = TextParser.parse("/join john}doe")
      assert {:join, "john-doe"} = TextParser.parse("/join john=doe")
      assert {:join, "john-doe"} = TextParser.parse("/join john*doe")
      assert {:join, "john-doe"} = TextParser.parse("/join john+doe")
      assert {:join, "john-doe"} = TextParser.parse("/join john!doe")
      assert {:join, "john-doe"} = TextParser.parse("/join john@doe")
      assert {:join, "john-doe"} = TextParser.parse("/join john/doe")
      assert {:join, "john-doe"} = TextParser.parse("/join john\\doe")
      assert {:join, "john-doe"} = TextParser.parse("/join john'doe")
    end
  end

  describe "/leave" do
    test "should error without room name" do
      assert {:error, :invalid_argument} = TextParser.parse("/join")
      assert {:error, :invalid_argument} = TextParser.parse("/join ")
    end

    test "should replace any separator with dashes" do
      assert {:leave, "john-doe"} = TextParser.parse("/leave john doe")
      assert {:leave, "john-doe"} = TextParser.parse("/leave john_doe")
      assert {:leave, "john-doe"} = TextParser.parse("/leave john#doe")
      assert {:leave, "john-doe"} = TextParser.parse("/leave john%doe")
      assert {:leave, "john-doe"} = TextParser.parse("/leave john~doe")
      assert {:leave, "john-doe"} = TextParser.parse("/leave john$doe")
      assert {:leave, "john-doe"} = TextParser.parse("/leave john[doe")
      assert {:leave, "john-doe"} = TextParser.parse("/leave john]doe")
      assert {:leave, "john-doe"} = TextParser.parse("/leave john)doe")
      assert {:leave, "john-doe"} = TextParser.parse("/leave john(doe")
      assert {:leave, "john-doe"} = TextParser.parse("/leave john{doe")
      assert {:leave, "john-doe"} = TextParser.parse("/leave john}doe")
      assert {:leave, "john-doe"} = TextParser.parse("/leave john=doe")
      assert {:leave, "john-doe"} = TextParser.parse("/leave john*doe")
      assert {:leave, "john-doe"} = TextParser.parse("/leave john+doe")
      assert {:leave, "john-doe"} = TextParser.parse("/leave john!doe")
      assert {:leave, "john-doe"} = TextParser.parse("/leave john@doe")
      assert {:leave, "john-doe"} = TextParser.parse("/leave john/doe")
      assert {:leave, "john-doe"} = TextParser.parse("/leave john\\doe")
      assert {:leave, "john-doe"} = TextParser.parse("/leave john'doe")
    end
  end

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

  describe "/message" do
    test "should error without room name" do
      assert {:error, :invalid_argument} = TextParser.parse("/message hello")
      assert {:error, :invalid_argument} = TextParser.parse("/message hello ")
    end

    test "should error without message" do
      assert {:error, :invalid_argument} = TextParser.parse("/message lobby")
      assert {:error, :invalid_argument} = TextParser.parse("/message lobby ")
    end

    test "should only accept room names separated by dashes" do
      assert {:message, "room", "name hello"} = TextParser.parse("/message room name hello")
    end

    test "should replace any separator with dashes" do
      assert {:message, "john-doe", "hello world!"} =
               TextParser.parse("/message john_doe hello world!")

      assert {:message, "john-doe", "hello world!"} =
               TextParser.parse("/message john#doe hello world!")

      assert {:message, "john-doe", "hello world!"} =
               TextParser.parse("/message john%doe hello world!")

      assert {:message, "john-doe", "hello world!"} =
               TextParser.parse("/message john~doe hello world!")

      assert {:message, "john-doe", "hello world!"} =
               TextParser.parse("/message john$doe hello world!")

      assert {:message, "john-doe", "hello world!"} =
               TextParser.parse("/message john[doe hello world!")

      assert {:message, "john-doe", "hello world!"} =
               TextParser.parse("/message john]doe hello world!")

      assert {:message, "john-doe", "hello world!"} =
               TextParser.parse("/message john)doe hello world!")

      assert {:message, "john-doe", "hello world!"} =
               TextParser.parse("/message john(doe hello world!")

      assert {:message, "john-doe", "hello world!"} =
               TextParser.parse("/message john{doe hello world!")

      assert {:message, "john-doe", "hello world!"} =
               TextParser.parse("/message john}doe hello world!")

      assert {:message, "john-doe", "hello world!"} =
               TextParser.parse("/message john=doe hello world!")

      assert {:message, "john-doe", "hello world!"} =
               TextParser.parse("/message john*doe hello world!")

      assert {:message, "john-doe", "hello world!"} =
               TextParser.parse("/message john+doe hello world!")

      assert {:message, "john-doe", "hello world!"} =
               TextParser.parse("/message john!doe hello world!")

      assert {:message, "john-doe", "hello world!"} =
               TextParser.parse("/message john@doe hello world!")

      assert {:message, "john-doe", "hello world!"} =
               TextParser.parse("/message john/doe hello world!")

      assert {:message, "john-doe", "hello world!"} =
               TextParser.parse("/message john\\doe hello world!")

      assert {:message, "john-doe", "hello world!"} =
               TextParser.parse("/message john'doe hello world!")

      assert {:message, "john-doe", "hello world!"} =
               TextParser.parse("/message (john'doe) hello world!")
    end
  end
end
