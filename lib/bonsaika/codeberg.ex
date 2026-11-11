defmodule Bonsaika.Codeberg do
  require Logger
  use Tesla

  plug(Tesla.Middleware.JSON)
  plug(Tesla.Middleware.PathParams)
  plug(Tesla.Middleware.Query)

  plug(
    Tesla.Middleware.BaseUrl,
    Application.fetch_env!(:bonsaika, :forjego_server) <> "/api/v1"
  )

  plug(
    Tesla.Middleware.Headers,
    [{"authorization", "token " <> Application.fetch_env!(:bonsaika, :forjego_token)}]
  )

  def list_members() do
    org = organisation()
    get_organizations_users(org)
      |> Enum.map(fn user -> Map.fetch!(user, "username")  end)
  end

  def invite_to_organisation(codeberg_user) do
    body = %{}

   Logger.debug("Inviting #{codeberg_user}")
  
    put!("/teams/#{team_id()}/members/#{codeberg_user}", body)
  end

  def kick_from_organisation(codeberg_user) do
    body = %{}

   Logger.debug("Inviting #{codeberg_user}")
  
    delete!("/teams/#{team_id()}/members/#{codeberg_user}")
  end

  defp get_organizations_users(org) do
   %Tesla.Env{status: 200, body: body} =
    get!("/orgs/#{org}/members")
    body
  end

  defp organisation() do
    Application.fetch_env!(:bonsaika, :forjego_org)
  end

  defp team_id() do
    Application.fetch_env!(:bonsaika, :forjego_team)
  end
end
