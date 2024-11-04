defmodule ChatServer.Command.TextParser do
  def parse("/help" <> args) when is_binary(args) do
    case String.trim(args) |> String.split(" ", trim: true) do
      [] -> {:help, "all"}
      [command] -> {:help, command}
      _ -> {:error, :invalid_argument}
    end
  end

  def parse("/connect" <> args) when is_binary(args) do
    with username when is_binary(username) <- normalize(args) do
      {:connect, username}
    end
  end

  def parse("/create" <> args) when is_binary(args) do
    with room_name when is_binary(room_name) <- normalize(args) do
      {:create, room_name}
    end
  end

  def parse("/delete" <> args) when is_binary(args) do
    with room_name when is_binary(room_name) <- normalize(args) do
      {:delete, room_name}
    end
  end

  def parse("/join" <> args) when is_binary(args) do
    with room_name when is_binary(room_name) <- normalize(args) do
      {:join, room_name}
    end
  end

  def parse("/leave" <> args) when is_binary(args) do
    with room_name when is_binary(room_name) <- normalize(args) do
      {:leave, room_name}
    end
  end

  defp normalize(username) do
    case String.split(username, ~r/[^a-z0-9]/, trim: true)
         |> Enum.reject(&(&1 == ""))
         |> Enum.join("-") do
      "" -> {:error, :invalid_argument}
      normalized -> normalized
    end
  end
end
