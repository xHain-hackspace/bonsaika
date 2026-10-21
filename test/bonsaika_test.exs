defmodule BonsaikaTest do
  # not async, because the alias tests change the application env
  use ExUnit.Case, async: false

  alias Bonsaika.Test.{AuthentikMock, MatrixMock, ServiceMock}

  @room MatrixMock.room_id()
  @space "!space:x-hain.de"

  describe "update_matrix_room/0" do
    test "invites authentik members that are not in the room" do
      setup_mocks(
        [AuthentikMock.user("alice"), AuthentikMock.user("bob")],
        ["@alice:x-hain.de"],
        []
      )

      Bonsaika.update_matrix_room()

      assert_received {:matrix, :invite, @space, "@bob:x-hain.de"}
      assert_received {:matrix, :invite, @room, "@bob:x-hain.de"}
      refute_received {:matrix, :invite, _, "@alice:x-hain.de"}
      refute_received {:matrix, :kick, _, _}
    end

    test "kicks room members that are not in authentik" do
      setup_mocks([AuthentikMock.user("alice")], ["@alice:x-hain.de", "@mallory:x-hain.de"], [])

      Bonsaika.update_matrix_room()

      assert_received {:matrix, :kick, @room, "@mallory:x-hain.de"}
      refute_received {:matrix, :kick, _, "@alice:x-hain.de"}
      refute_received {:matrix, :invite, _, _}
    end

    test "kicks invited users that are not in authentik" do
      setup_mocks([AuthentikMock.user("alice")], ["@alice:x-hain.de"], ["@mallory:x-hain.de"])

      Bonsaika.update_matrix_room()

      assert_received {:matrix, :kick, @room, "@mallory:x-hain.de"}
    end

    test "does not kick whitelisted users" do
      setup_mocks([AuthentikMock.user("alice")], ["@alice:x-hain.de", "@bot:x-hain.de"], [])

      Bonsaika.update_matrix_room()

      refute_received {:matrix, :kick, _, _}
    end

    test "does not re-invite users that are already invited" do
      setup_mocks([AuthentikMock.user("alice")], [], ["@alice:x-hain.de"])

      Bonsaika.update_matrix_room()

      refute_received {:matrix, :invite, _, _}
      refute_received {:matrix, :kick, _, _}
    end

    test "does nothing when authentik and the room are in sync" do
      setup_mocks(
        [AuthentikMock.user("alice"), AuthentikMock.user("bob")],
        ["@alice:x-hain.de"],
        ["@bob:x-hain.de"]
      )

      Bonsaika.update_matrix_room()

      refute_received {:matrix, :invite, _, _}
      refute_received {:matrix, :kick, _, _}
    end

    test "user changes from xhain account to external matrix account" do
      setup_mocks([AuthentikMock.user("alice", "@alice:matrix.org")], ["@alice:x-hain.de"], [])

      Bonsaika.update_matrix_room()

      assert_received {:matrix, :invite, @room, "@alice:matrix.org"}
      assert_received {:matrix, :kick, @room, "@alice:x-hain.de"}
    end

    test "falls back to the x-hain account if the external matrix account is empty" do
      setup_mocks([AuthentikMock.user("alice", "")], [], [])

      Bonsaika.update_matrix_room()

      assert_received {:matrix, :invite, @room, "@alice:x-hain.de"}
    end

    test "resolves a room alias to its room id" do
      room_alias = "#room:x-hain.de"
      previous = Application.fetch_env!(:bonsaika, :matrix_room)
      Application.put_env(:bonsaika, :matrix_room, room_alias)
      on_exit(fn -> Application.put_env(:bonsaika, :matrix_room, previous) end)

      setup_mocks([AuthentikMock.user("alice")], [], [])

      Bonsaika.update_matrix_room()

      assert_received {:matrix, :resolve_alias, ^room_alias}
      assert_received {:matrix, :invite, @room, "@alice:x-hain.de"}
    end

    test "resolves a space alias to its room id" do
      space_alias = "#space:x-hain.de"
      previous = Application.fetch_env!(:bonsaika, :matrix_space)
      Application.put_env(:bonsaika, :matrix_space, space_alias)
      on_exit(fn -> Application.put_env(:bonsaika, :matrix_space, previous) end)

      setup_mocks([AuthentikMock.user("alice")], [], [])

      Bonsaika.update_matrix_room()

      assert_received {:matrix, :resolve_alias, ^space_alias}
      assert_received {:matrix, :invite, @space, "@alice:x-hain.de"}
    end
  end

  defp setup_mocks(authentik_users, joined, invited) do
    ServiceMock.mock([
      AuthentikMock.service(authentik_users),
      MatrixMock.service(joined, invited)
    ])
  end
end
