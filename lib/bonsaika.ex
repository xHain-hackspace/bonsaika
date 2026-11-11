defmodule Bonsaika do
  require Logger
  alias Jason
  alias Bonsaika.{Authentik, Matrix, Codeberg}

  def update_matrix_room() do
    Logger.info("Running update of the member channel")
    authentik_members = Authentik.list_members() |> Enum.uniq() |> Enum.sort()
    {joined, invited} = Matrix.list_members()
    matrix_members = (joined ++ invited) |> Enum.uniq() |> Enum.sort()

    users_to_add = authentik_members -- matrix_members

    whitelist = Application.fetch_env!(:bonsaika, :whitelist)

    users_to_remove =
      (matrix_members -- authentik_members) |> Enum.reject(fn member -> member in whitelist end)

    Logger.info("To be added: #{users_to_add |> Jason.encode!()}")
    Logger.info("To be removed: #{users_to_remove |> Jason.encode!()}")

    # add to space
    Enum.map(users_to_add, &Matrix.invite_to_space/1)

    # add to room
    Enum.map(users_to_add, &Matrix.invite_to_room/1)

    # remove from room
    Enum.map(users_to_remove, &Matrix.kick_from_room/1)
  end

  def update_codeberg_team() do
    Logger.info("Updating the codeberg team")
    rechenwerk_members = Authentik.list_rechenwerk_members()
    coderberg_members = Codeberg.list_members() |> Enum.uniq() |> Enum.sort()

    users_to_add = rechenwerk_members -- coderberg_members

    whitelist = Application.fetch_env!(:bonsaika, :codeberg_whitelist)

    users_to_remove = (coderberg_members --  rechenwerk_members) |> Enum.reject(fn member -> member in whitelist end)

    Logger.info("To be added: #{users_to_add |> Jason.encode!()}")
    Logger.info("To be removed: #{users_to_remove |> Jason.encode!()}")

    # add to the team
    Enum.map(users_to_add, &Codeberg.invite_to_organisation/1)

    # remove from room
    Enum.map(users_to_remove, &Codeberg.kick_from_organisation/1)
  end
end
