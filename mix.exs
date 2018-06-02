defmodule Murmur.Mixfile do
  use Mix.Project

  @description """
  Murmur is a pure Elixir implementation of the non-cryptographic hash Murmur3.

  It aims to implement the x86_32bit, x86_128bit and x64_128bit variants.
  """
  @github "https://github.com/gmcabrita/murmur"

  def project() do
    [
      app: :murmur,
      name: "Murmur",
      source_url: @github,
      homepage_url: nil,
      version: "1.0.1-dev",
      elixir: "~> 1.0",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: @description,
      package: package(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      docs: docs()
    ]
  end

  def application() do
    []
  end

  defp docs() do
    [
      main: "readme",
      logo: nil,
      extras: ["README.md"]
    ]
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Gonçalo Cabrita"],
      licenses: ["MIT"],
      links: %{"GitHub" => @github}
    ]
  end

  defp deps() do
    [
      {:excoveralls, "~> 0.8", only: :docs, runtime: false},
      {:ex_doc, "~> 0.16", only: :docs, runtime: false},
      {:inch_ex, "~> 0.5", only: :docs, runtime: false},
      {:dialyzex, "~> 1.1.2", only: [:dev, :test], runtime: false}
    ]
  end
end
