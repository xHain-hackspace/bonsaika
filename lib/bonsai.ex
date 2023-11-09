defmodule Bonsaika do
  import Authentik
  import Jason

  def update_matrix_room() do
    members = list_members() |> Enum.sort() |> encode!()
    File.write("output.json", members)
  end
end
