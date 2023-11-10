defmodule Matrix do
  require Logger
  use Tesla

  plug(Tesla.Middleware.JSON)
  plug(Tesla.Middleware.PathParams)
  plug(Tesla.Middleware.Query)

  plug(
    Tesla.Middleware.BaseUrl,
    Application.get_env(:bonsaika, :matrix_server) <> "/_matrix/client/v3/"
  )

  plug(Tesla.Middleware.BearerAuth,
    token: Application.get_env(:bonsaika, :matrix_token)
  )

  def list_members() do
    matrix_room = Application.get_env(:bonsaika, :matrix_room)

    room =
      if is_room_id(matrix_room) do
        matrix_room
      else
        resolve_room_alias(matrix_room)
      end

    get_joined_users(room)
    |> Enum.concat(get_invited_users(room))
  end

  defp get_joined_users(room) do
    get!("/rooms/" <> room <> "/members", query: [membership: "join"]).body
    |> Map.get("chunk")
    |> extract_matrix_users()
  end

  defp get_invited_users(room) do
    get!("/rooms/" <> room <> "/members", query: [membership: "invite"]).body
    |> Map.get("chunk")
    |> extract_matrix_users()
  end

  defp extract_matrix_users(chunk) do
    Enum.map(chunk, fn event -> event["state_key"] end)
  end

  defp resolve_room_alias(room_alias) do
    room_alias = URI.encode(room_alias, &(&1 != ?#))
    params = [room_alias: room_alias]

    get!("/directory/room/:room_alias", opts: [path_params: params]).body
    |> Map.get("room_id")
  end

  defp is_room_id(input) do
    regex_pattern =
      ~r/^![[:alnum:]]+:[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b[-a-zA-Z0-9@:%_\+.~#?&\/\/=]*/

    String.match?(input, regex_pattern)
  end
end
