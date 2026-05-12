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

  defp matrix_room() do
    Application.fetch_env!(:bonsaika, :matrix_room)
  end 

  defp matrix_space do
    Application.fetch_env!(:bonsaika, :matrix_space)
  end

  def list_members() do
    room =
      if is_room_id(matrix_room()) do
        matrix_room()
      else
        resolve_room_alias(matrix_room())
      end

    left = get_left_users(room) |> Jason.encode!()
    File.write!("left.json", left)

    {get_joined_users(room), get_invited_users(room)}
  end

  def invite_to_space(matrix_user) do
    body = %{
      user_id: matrix_user
    }

    post!("/rooms/#{matrix_space()}/invite", body)
  end

  def invite_to_room(matrix_user) do
    body = %{
      user_id: matrix_user
    }

    Logger.info("Inviting #{matrix_user}")

    post!("/rooms/#{matrix_room()}/invite", body) |> dbg()
  end

  def kick_from_room(matrix_user) do
    body = %{
      membership: "leave",
      reason: "Not a member"
    }

    %Tesla.Env{status: 200} =
      put!("/rooms/#{matrix_room()}/state/m.room.member/#{matrix_user}", body)
  end

  defp get_joined_users(room) do
    get!("/rooms/" <> room <> "/members", query: [membership: "join"]).body
    |> Map.get("chunk")
    |> extract_matrix_users()
  end

  defp get_invited_users(room) do
    %Tesla.Env{status: 200, body: body} =
      get!("/rooms/" <> room <> "/members", query: [membership: "invite"])

    body
    |> Map.get("chunk")
    |> extract_matrix_users()
  end

  defp get_left_users(room) do
    %Tesla.Env{status: 200, body: body} =
      get!("/rooms/" <> room <> "/members", query: [membership: "leave"])

    body
    |> Map.get("chunk")
    |> extract_matrix_users()
  end

  defp extract_matrix_users(chunk) do
    Enum.map(chunk, fn event -> event["state_key"] end)
  end

  defp resolve_room_alias(room_alias) do
    room_alias = URI.encode(room_alias, &(&1 != ?#))
    params = [room_alias: room_alias]

    %Tesla.Env{status: 200, body: body} =
      get!("/directory/room/:room_alias", opts: [path_params: params])

    body
    |> Map.get("room_id")
  end

  defp is_room_id(input) do
    regex_pattern =
      ~r/^![[:alnum:]]+:[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b[-a-zA-Z0-9@:%_\+.~#?&\/\/=]*/

    String.match?(input, regex_pattern)
  end
end
