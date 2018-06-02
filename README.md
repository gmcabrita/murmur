Murmur
======

[![Build Status](https://img.shields.io/travis/gmcabrita/murmur.svg?style=flat)](https://travis-ci.org/gmcabrita/murmur)
[![Coverage Status](https://img.shields.io/coveralls/gmcabrita/murmur.svg?style=flat)](https://coveralls.io/r/gmcabrita/murmur?branch=master)
[![Hex docs](http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat)](https://hexdocs.pm/murmur)
[![Hex Version](http://img.shields.io/hexpm/v/murmur.svg?style=flat)](https://hex.pm/packages/murmur)
[![License](http://img.shields.io/hexpm/l/murmur.svg?style=flat)](https://github.com/gmcabrita/murmur/blob/master/LICENSE)

Murmur is a pure Elixir implementation of the non-cryptographic hash [Murmur3](https://code.google.com/p/smhasher/wiki/MurmurHash3).

It aims to implement the x86_32bit, x86_128bit and x64_128bit variants.

# Usage

Add Murmur as a dependency in your mix.exs file.

```elixir
def deps do
  [{:murmur, "~> 1.0"}]
end
```

When you are done, run `mix deps.get` in your shell to fetch and compile Murmur.


# Examples

```iex
iex> Murmur.hash_x86_32("b2622f5e1310a0aa14b7f957fe4246fa", 2147368987)
3297211900

iex> Murmur.hash_x86_128("some random data")
5586633072055552000169173700229798482

iex> Murmur.hash_x64_128([:yes, :you, :can, :use, :any, :erlang, :term!])
300414073828138369336317731503972665325
```
