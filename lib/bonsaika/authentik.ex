defmodule Bonsaika.Authentik do
  require Logger
  use Tesla

  plug(Tesla.Middleware.JSON)

  plug(
    Tesla.Middleware.BaseUrl,
    Application.fetch_env!(:bonsaika, :authentik_server) <> "/api/v3/"
  )

  plug(Tesla.Middleware.BearerAuth,
    token: Application.fetch_env!(:bonsaika, :authentik_token)
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
      {:ok, value} when value != "" ->
        value

      _ ->
        username = Map.fetch!(user, "username")
        "@" <> username <> ":x-hain.de"
    end
  end

  defp external_matrix_account(user) do
    user
    |> Map.fetch!("attributes")
    |> Map.fetch("external-matrix-account")
  end
end
