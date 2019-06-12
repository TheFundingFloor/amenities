defmodule Amenities.MixProject do
  use Mix.Project

  def project do
    [
      app: :amenities,
      version: "1.0.0",
      elixir: ">= 1.6.0",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, ">= 2.2.11", optional: true},
      {:money, ">= 1.3.0", optional: true},
      {:decimal, ">= 1.5.0", optional: true},

      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},

      {:mix_test_watch, "~> 0.9", only: :dev, runtime: false},

      # Static Analysis
      {:credo, "~> 1.0.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev], runtime: false}
    ]
  end
end
