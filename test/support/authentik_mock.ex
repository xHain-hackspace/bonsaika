defmodule Bonsaika.Test.AuthentikMock do
  @moduledoc """
  Mock of the Authentik API, to be used with `Bonsaika.Test.ServiceMock`.
  """

  import ExUnit.Assertions
  import Tesla.Mock, only: [json: 1]

  @doc "Serves `users` as the members of the configured group."
  def service(users) do
    base_url = Application.fetch_env!(:bonsaika, :authentik_server) <> "/api/v3"
    group = Application.fetch_env!(:bonsaika, :authentik_group)

    {base_url,
     fn :get, "/core/groups/", env ->
       assert env.query == [name: group]
       json(%{"results" => [%{"users_obj" => users}]})
     end}
  end

  @doc "Builds a user as returned in the `users_obj` of a group."
  def user(username, external_matrix_account \\ nil) do
    attributes =
      if external_matrix_account,
        do: %{"external-matrix-account" => external_matrix_account},
        else: %{}

    %{"username" => username, "attributes" => attributes}
  end
end
