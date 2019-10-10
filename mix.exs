defmodule AbsinthePaginator.MixProject do
  use Mix.Project

  def project do
    [
      app: :absinthe_paginator,
      version: "0.2.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases()
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
      {:absinthe_relay, "~> 1.4", runtime: false},
      {:ecto_sql, "~> 3.0", runtime: false},
      {:postgrex, ">= 0.0.0", runtime: false},
      {:paginator, git: "https://github.com/duffelhq/paginator.git", branch: "master"},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end

  def elixirc_paths(:test), do: ["lib", "test/support"]
  def elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      # Ensures database is reset before tests are run
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
