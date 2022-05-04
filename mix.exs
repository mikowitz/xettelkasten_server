defmodule XettelkastenServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :xettelkasten_server,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {XettelkastenServer.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:earmark, "~> 1.4.24"},
      {:file_system, "~> 0.2"},
      {:floki, "~> 0.32.0", only: [:dev, :test]},
      {:plug_cowboy, "~> 2.0"},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:mox, "~> 1.0", onoly: :test},
      {:yaml_elixir, "~> 2.8"}
    ]
  end
end
