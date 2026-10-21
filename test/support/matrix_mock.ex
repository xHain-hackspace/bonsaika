defmodule Bonsaika.Test.MatrixMock do
  @moduledoc """
  Mock of the Matrix client API, to be used with `Bonsaika.Test.ServiceMock`.

  Invites and kicks are sent to the calling process as
  `{:matrix, :invite, room, user}` and `{:matrix, :kick, room, user}`.
  Room aliases are resolved to `room_id/0` and reported as
  `{:matrix, :resolve_alias, room_alias}`.
  """

  import ExUnit.Assertions
  import Tesla.Mock, only: [json: 1]

  @room_id "!room:x-hain.de"

  def room_id, do: @room_id

  @doc "Serves `joined` and `invited` as the members of the room."
  def service(joined, invited) do
    base_url = Application.fetch_env!(:bonsaika, :matrix_server) <> "/_matrix/client/v3"
    test_pid = self()

    {base_url,
     fn
       :get, "/directory/room/" <> room_alias, _env ->
         send(test_pid, {:matrix, :resolve_alias, room_alias})
         json(%{"room_id" => @room_id})

       :get, "/rooms/" <> @room_id <> "/members", env ->
         users =
           case Keyword.fetch!(env.query, :membership) do
             "join" -> joined
             "invite" -> invited
           end

         json(%{"chunk" => Enum.map(users, &%{"state_key" => &1})})

       :post, "/rooms/" <> rest, env ->
         [room, "invite"] = String.split(rest, "/")
         send(test_pid, {:matrix, :invite, room, Jason.decode!(env.body)["user_id"]})
         json(%{})

       :put, "/rooms/" <> rest, env ->
         [room, "state", "m.room.member", user] = String.split(rest, "/")
         assert %{"membership" => "leave"} = Jason.decode!(env.body)
         send(test_pid, {:matrix, :kick, room, user})
         json(%{})
     end}
  end
end
