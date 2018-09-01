defmodule Transmitter.MixProject do
  use Mix.Project

  def project do
    [
      app: :transmitter,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:cowboy, :plug, :httpoison],
      extra_applications: [:logger],
      mod: {Transmitter.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 2.0"},
      {:plug, "~> 1.0"},
      {:httpoison, "~> 1.1.1"},
      {:couchdb, github: "7h0ma5/elixir-couchdb"},
      {:comeonin, "~> 4.0"},
      {:bcrypt_elixir, "~> 1.0"},
      {:timex, "~> 3.1"},
    ]
  end
end
