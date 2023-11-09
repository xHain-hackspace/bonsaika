defmodule Authentik do
  use Tesla

  plug(Tesla.Middleware.JSON)
  plug(Tesla.Middleware.BearerAuth, token: System.fetch_env!("BONSAIKA_AUTHENTIK_TOKEN"))
  plug(Tesla.Middleware.BaseUrl, System.fetch_env!("BONSAIKA_AUTHENTIK_SERVER") <> "/api/v3/")

  def list_members() do
    member_group()
    |> Map.fetch!("users_obj")
    |> Enum.map(fn user ->
      matrix_user(user)
    end)
  end

  defp member_group() do
    # there should be only one result
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
    case user |> Map.fetch!("attributes") |> Map.fetch("external-matrix-account") do
      {:ok, value} when value != "" ->
        {:ok, value}

      _ ->
        {:error}
    end
  end
end
