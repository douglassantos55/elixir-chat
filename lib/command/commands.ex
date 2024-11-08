defmodule ChatServer.Command.Commands do
  @commands [
    "rooms",
    "connect",
    "create",
    "delete",
    "join",
    "leave",
    "message",
    "private"
  ]

  def list(), do: @commands

  def help("all") do
    message = [
      "Available commands:\r\n\r\n",
      for command <- list() do
        help(command)
      end
    ]

    IO.iodata_to_binary(message)
  end

  def help("rooms") do
    "/rooms\t\t\t\tList all rooms created.\r\n"
  end

  def help("connect") do
    "/connect [username]\t\tAuthenticates using the given username.\r\n"
  end

  def help("create") do
    "/create [room-name]\t\tCreates a room with the given name.\r\n"
  end

  def help("delete") do
    "/delete [room-name]\t\tDeletes a created room. You must be the one who created the room.\r\n"
  end

  def help("join") do
    "/join [room-name]\t\tJoin an existing room. You'll be able to receive and send messages in this room.\r\n"
  end

  def help("leave") do
    "/leave [room-name]\t\tLeave a room. You'll not be able to receive or send messages to this room.\r\n"
  end

  def help("message") do
    "/message [room-name] [message]\tSends the given message to the informed room.\r\n"
  end

  def help("private") do
    "/private [username] [message]\tSends a private message to the given username.\r\n"
  end

  def help(_), do: "Invalid command. Use /help to list the available commands.\r\n"
end
