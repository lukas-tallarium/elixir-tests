defmodule Mixfile do
  use Mix.Project

  def project do
    [
      app: :tests,
      version: "0.1.0",
      elixir: "~> 1.18.4",
      deps: deps(),
    ]
  end

  defp deps do
    [
      {:emlx, github: "elixir-nx/emlx", branch: "main", sparse: "emlx"},
      # {:exla, "~> 0.12.0"},
      {:nx, "~> 0.12.0"},
    ]
  end
end
