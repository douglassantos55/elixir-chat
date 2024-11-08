defmodule ChatServer.Command.TextParser do
  def parse("/help" <> args) when is_binary(args) do
    case validate_args(args) do
      command when is_binary(command) ->
        {:help, command}

      {:error, :invalid_argument} ->
        # no args
        {:help, "all"}

      {:error, reason} ->
        # args /helpa something
        {:error, reason}

      _ ->
        {:help, "all"}
    end
  end

  def parse("/rooms" <> args) do
    case String.trim(args) == "" do
      true -> {:rooms}
      false -> {:error, :invalid_argument}
    end
  end

  def parse("/connect" <> args) when is_binary(args) do
    with username when is_binary(username) <- validate_args(args) do
      {:connect, username}
    end
  end

  def parse("/create" <> args) when is_binary(args) do
    with room_name when is_binary(room_name) <- validate_args(args) do
      {:create, room_name}
    end
  end

  def parse("/delete" <> args) when is_binary(args) do
    with room_name when is_binary(room_name) <- validate_args(args) do
      {:delete, room_name}
    end
  end

  def parse("/join" <> args) when is_binary(args) do
    with room_name when is_binary(room_name) <- validate_args(args) do
      {:join, room_name}
    end
  end

  def parse("/leave" <> args) when is_binary(args) do
    with room_name when is_binary(room_name) <- validate_args(args) do
      {:leave, room_name}
    end
  end

  def parse("/message" <> args) do
    with params when is_binary(params) <- validate_args(args) do
      case String.split(args, " ", parts: 2, trim: true) do
        [room_name, message] ->
          {:message, normalize(room_name), message}

        _ ->
          {:error, :invalid_argument}
      end
    end
  end

  def parse(_) do
    {:error, :invalid_command}
  end

  defp validate_args(args) when is_binary(args) do
    case String.split(args, ~r/[\r\n]+/, trim: false, parts: 2) do
      [] ->
        validate_arguments(args)

      [params] ->
        validate_arguments(params)

      [params, _] ->
        validate_arguments(params)
    end
  end

  defp validate_arguments(args) when args != "" do
    case String.starts_with?(args, " ") do
      true -> normalize(args)
      false -> {:error, :invalid_command}
    end
  end

  defp validate_arguments(_args) do
    {:error, :invalid_argument}
  end

  defp normalize(name, separator \\ "-") do
    case String.split(name, ~r/[^a-z0-9]/, trim: true)
         |> Enum.reject(&(&1 == ""))
         |> Enum.join(separator) do
      "" -> {:error, :invalid_argument}
      normalized -> normalized
    end
  end
end
