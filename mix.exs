defmodule Bonsaika.MixProject do
  use Mix.Project

  def project do
    [
      app: :bonsaika,
      version: "0.1.0",
      elixir: "~> 1.15",
      aliases: aliases(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        bonsaika: [
          include_executables_for: [:unix],
          applications: [runtime_tools: :permanent]
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Bonsaika.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.4"},
      {:jason, "~> 1.4"},
      {:quantum, "~> 3.0"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get"]
    ]
  end
end
