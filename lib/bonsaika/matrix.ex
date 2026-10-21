defmodule Bonsaika.Matrix do
  require Logger
  use Tesla

  plug(Tesla.Middleware.JSON)
  plug(Tesla.Middleware.PathParams)
  plug(Tesla.Middleware.Query)

  plug(
    Tesla.Middleware.BaseUrl,
    Application.fetch_env!(:bonsaika, :matrix_server) <> "/_matrix/client/v3/"
  )

  plug(Tesla.Middleware.BearerAuth,
    token: Application.fetch_env!(:bonsaika, :matrix_token)
  )

  def list_members() do
    room = matrix_room()
    {get_joined_users(room), get_invited_users(room)}
  end

  def invite_to_room(matrix_user) do
    body = %{
      user_id: matrix_user
    }

    Logger.debug("Inviting #{matrix_user}")

    post!("/rooms/#{matrix_room()}/invite", body)
  end

  def kick_from_room(matrix_user) do
    body = %{
      membership: "leave",
      reason: "Not a member"
    }

    Logger.debug("Kicking #{matrix_user}")

    %Tesla.Env{status: 200} =
      put!("/rooms/#{matrix_room()}/state/m.room.member/#{matrix_user}", body)
  end

  defp get_joined_users(room) do
    %Tesla.Env{status: 200, body: body} =
      get!("/rooms/" <> room <> "/members", query: [membership: "join"])

    extract_matrix_users(body)
  end

  defp get_invited_users(room) do
    %Tesla.Env{status: 200, body: body} =
      get!("/rooms/" <> room <> "/members", query: [membership: "invite"])

    extract_matrix_users(body)
  end

  defp extract_matrix_users(body) do
    body
    |> Map.get("chunk")
    |> Enum.map(fn event -> event["state_key"] end)
  end

  defp resolve_room_alias(room_alias) do
    # PathParams takes care of encoding the alias
    params = [room_alias: room_alias]

    %Tesla.Env{status: 200, body: body} =
      get!("/directory/room/:room_alias", opts: [path_params: params])

    body |> Map.get("room_id")
  end

  defp is_room_id(input) do
    regex_pattern =
      ~r/^![[:alnum:]]+:[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b[-a-zA-Z0-9@:%_\+.~#?&\/\/=]*/

    String.match?(input, regex_pattern)
  end

  defp matrix_room() do
    input = Application.fetch_env!(:bonsaika, :matrix_room)

    if is_room_id(input) do
      input
    else
      resolve_room_alias(input)
    end
  end
end
