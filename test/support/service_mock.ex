defmodule Bonsaika.Test.ServiceMock do
  @moduledoc """
  Routes mocked HTTP requests to the mock of the service they are sent to.

  Each service mock returns a `{base_url, handler}` tuple. A request whose url
  starts with `base_url` is passed to `handler.(method, path, env)`, where
  `path` is the url relative to `base_url`.
  """

  def mock(services) do
    Tesla.Mock.mock(fn env ->
      Enum.find_value(services, fn {base_url, handler} ->
        case String.split_at(env.url, String.length(base_url)) do
          {^base_url, path} -> handler.(env.method, URI.decode(path), env)
          _ -> nil
        end
      end) || raise "no service mock for #{env.method |> to_string() |> String.upcase()} #{env.url}"
    end)
  end
end
