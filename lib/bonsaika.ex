defmodule Bonsaika do
  require Logger
  alias Jason
  alias Bonsaika.{Authentik, Matrix}

  @whitelist Application.compile_env!(:bonsaika, :whitelist)

  def update_matrix_room() do
    Logger.info("Running update of the member channel")
    authentik_members = Authentik.list_members() |> Enum.dedup() |> Enum.sort()
    {joined, invited} = Matrix.list_members()
    matrix_members = (joined ++ invited) |> Enum.dedup() |> Enum.sort()

    users_to_add = get_users_to_add(authentik_members, matrix_members)
    users_to_remove = get_users_to_remove(authentik_members, matrix_members)

    Logger.info("To be added: #{users_to_add |> Jason.encode!()}")
    Logger.info("To be removed: #{users_to_remove |> Jason.encode!()}")

    # add to space
    Enum.map(users_to_add, &Matrix.invite_to_space/1)

    # add to room
    Enum.map(users_to_add, &Matrix.invite_to_room/1)

    # remove from room
    Enum.map(users_to_remove, &Matrix.kick_from_room/1)
  end

  defp get_users_to_add(authentik_members, matrix_members) do
    authentik_members -- matrix_members
  end

  defp get_users_to_remove(authentik_members, matrix_members) do
    (matrix_members -- authentik_members) |> Enum.reject(fn member -> member in @whitelist end)
  end
end
