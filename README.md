Murmur [![Build Status](https://travis-ci.org/gmcabrita/murmur.png?branch=master)](https://travis-ci.org/gmcabrita/murmur) [![Coverage Status](https://img.shields.io/coveralls/gmcabrita/murmur.svg)](https://coveralls.io/r/gmcabrita/murmur?branch=master)
========

Murmur is a pure Elixir implementation of the non-cryptographic hash [Murmur3](https://code.google.com/p/smhasher/wiki/MurmurHash3).

It aims to implement the x86_32bit, x86_128bit and x64_128bit variants.

# Usage

```iex
iex> Murmur.hash(:x86_32, "b2622f5e1310a0aa14b7f957fe4246fa", 2147368987)
3297211900
iex> Murmur.hash(:x86_128, "some random data")
5586633072055552000169173700229798482
iex> Murmur.hash(:x86_128, [:yes, :you, :can, :use, :any, :erlang, :term!])
199500574519892953329319269380928016587
```
