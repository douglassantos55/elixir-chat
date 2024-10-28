defmodule ChatServer.Command.TextParser do
  def parse("/connect" <> args) when is_binary(args) do
    with username when is_binary(username) <- normalize_username(args) do
      {:connect, username}
    end
  end

  defp normalize_username(username) do
    case String.split(username, ~r/[^a-z0-9]/, trim: true)
         |> Enum.reject(&(&1 == ""))
         |> Enum.join("-") do
      "" -> {:error, :invalid_argument}
      normalized -> normalized
    end
  end
end
