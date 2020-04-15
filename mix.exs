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
      version: "1.0.2",
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: @description,
      package: package(),
      deps: deps(),
      aliases: aliases(),
      preferred_cli_env: [
        ci: :test
      ],
      test_coverage: [tool: ExCoveralls],
      docs: docs(),
      dialyzer_ignored_warnings: [
        {:warn_contract_supertype, :_, {:extra_range, [:_, :__protocol__, 1, :_, :_]}}
      ]
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
      {:excoveralls, "~> 0.10", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.16", only: [:dev, :docs], runtime: false},
      {:dialyzex, "~> 1.2.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      ci: [
        "format --check-formatted",
        "test",
        "dialyzer"
      ]
    ]
  end
end
