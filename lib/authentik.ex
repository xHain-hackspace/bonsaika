defmodule Authentik do
  require Logger
  use Tesla

  plug(Tesla.Middleware.JSON)

  plug(
    Tesla.Middleware.BaseUrl,
    Application.get_env(:bonsaika, :authentik_server) <> "/api/v3/"
  )

  plug(Tesla.Middleware.BearerAuth,
    token: Application.get_env(:bonsaika, :authentik_token)
  )

  def list_members() do
    member_group()
    |> Map.fetch!("users_obj")
    |> Enum.map(fn user ->
      matrix_user(user)
    end)
  end

  defp member_group() do
    # there should be only one result when searching for 'member' group
    get!("/core/groups/", query: [name: "member"]).body
    |> Map.fetch!("results")
    |> Enum.at(0)
  end

  defp matrix_user(user) do
    case external_matrix_account(user) do
      {:ok, value} ->
        value

      {:error} ->
        username = Map.fetch!(user, "username")
        "@" <> username <> ":x-hain.de"
    end
  end

  defp external_matrix_account(user) do
    case user
         |> Map.fetch!("attributes")
         |> Map.fetch("external-matrix-account") do
      {:ok, value} when value != "" ->
        {:ok, value}

      _ ->
        {:error}
    end
  end
end
