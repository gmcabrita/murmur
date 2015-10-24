defmodule Murmur.Mixfile do
  use Mix.Project

  @description """
  Murmur is a pure Elixir implementation of the non-cryptographic hash Murmur3.

  It aims to implement the x86_32bit, x86_128bit and x64_128bit variants.
  """

  def project do
    [app: :murmur,
     version: "1.0.0",
     elixir: "~> 1.0",
     description: @description,
     package: package,
     deps: deps,
     aliases: [dialyze: "dialyze --unmatched-returns --error-handling --race-conditions --underspecs"],
     test_coverage: [tool: ExCoveralls]]
  end

  def application do
    [applications: []]
  end

  def package do
    [files: ["lib", "mix.exs", "README.md", "LICENSE"],
     maintainers: ["Gonçalo Cabrita"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/gmcabrita/murmur"}
    ]
  end

  defp deps do
    [{:excoveralls, "~> 0.3", only: :dev},
     {:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.10", only: :dev},
     {:dogma, "~> 0.0", only: :dev},
     {:inch_ex, only: :docs}
    ]
  end

end
