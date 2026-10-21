defmodule Bonsaika.MixProject do
  use Mix.Project

  def project do
    [
      app: :bonsaika,
      version: "0.1.0",
      elixir: "~> 1.19",
      aliases: aliases(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
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

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

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
