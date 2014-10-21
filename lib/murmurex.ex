defmodule Murmurex do
  @moduledoc """
  This module implements the x86_32, x86_128 and x64_128 variants of the
  non-cryptographic hash Murmur3.
  """

  use Bitwise

  @c1_32  0xcc9e2d51
  @c2_32  0x1b873593
  @n_32   0xe6546b64

  # since erlang/elixir integers are variable-length we have to guarantee them
  # to be 32 or 64 bit long
  defmacrop mask_32(x), do: quote do: unquote(x) &&& 0xFFFFFFFF
  defmacrop mask_64(x), do: quote do: unquote(x) &&& 0xFFFFFFFFFFFFFFFF

  @doc """
  Returns the hashed `term` using hash variant `type` and the provided `seed`.
  """
  @spec hash(atom, term, pos_integer) :: pos_integer
  def hash(type, data, seed \\ 0) do
   case type do
     :x86_32  ->  hash_x86_32(data, seed)
   end
  end

  @spec hash_x86_32(binary, pos_integer) :: pos_integer
  defp hash_x86_32(data, seed) when is_binary(data) do
    hash =
      case hash_32_aux(seed, data) do
        {h, []} -> h
        {h, t}  -> h ^^^ ((swap_uint32(t) * @c1_32)
                         |> mask_32 |> rotl32(15) |> Kernel.*(@c2_32) |> mask_32)
      end

    fmix32(hash ^^^ byte_size(data))
  end

  @spec hash_x86_32(term, pos_integer) :: pos_integer
  defp hash_x86_32(data, seed) do
    hash_x86_32(:erlang.term_to_binary(data), seed)
  end

  @spec hash_32_aux(pos_integer, binary) :: {pos_integer, [binary]}
  defp hash_32_aux(h0, <<k :: size(8)-unsigned-little-integer-unit(4), t :: binary>>) do
    k1 = mask_32(k * @c1_32) |> rotl32(15) |> mask_32 |> Kernel.*(@c2_32) |> mask_32
    (rotl32(h0 ^^^ k1, 13) * 5 + @n_32) |> mask_32 |> hash_32_aux(t)
  end

  @spec hash_32_aux(pos_integer, [binary]) :: {pos_integer, [binary]}
  defp hash_32_aux(h, t) when byte_size(t) > 0, do: {h, t}
  defp hash_32_aux(h, _), do: {h, []}

  @spec fmix32(pos_integer) :: pos_integer
  defp fmix32(h0) do
    xorbsr(h0, 16) * 0x85ebca6b
    |> mask_32 |> xorbsr(13) |> Kernel.*(0xc2b2ae35) |> mask_32 |> xorbsr(16)
  end

  @spec fmix64(pos_integer) :: pos_integer
  defp fmix64(h0) do
    xorbsr(h0, 33) * 0xff51afd7ed558ccd
    |> mask_64 |> xorbsr(33) |> Kernel.*(0xc4ceb9fe1a85ec53) |> mask_64 |> xorbsr(33)
  end

  @spec swap_uint32(binary) :: pos_integer
  defp swap_uint32(<< v1 :: size(8)-unsigned-little-integer,
                      v2 :: size(8)-unsigned-little-integer,
                      v3 :: size(8)-unsigned-little-integer >>) do
    ((v3 <<< 16) ^^^ (v2 <<< 8)) ^^^ v1
  end

  defp swap_uint32(<< v1 :: size(8)-unsigned-little-integer,
                      v2 :: size(8)-unsigned-little-integer >>) do
    (v2 <<< 8) ^^^ v1
  end

  defp swap_uint32(<< v1 :: size(8)-unsigned-little-integer >>) do
    0 ^^^ v1
  end

  @spec xorbsr(pos_integer, pos_integer) :: pos_integer
  defp xorbsr(h, v), do: h ^^^ (h >>> v)

  @spec rotl32(pos_integer, pos_integer) :: pos_integer
  defp rotl32(x, r), do: ((x <<< r) ||| (x >>> (32 - r))) |> mask_32

  @spec rotl64(pos_integer, pos_integer) :: pos_integer
  defp rotl64(x, r), do: ((x <<< r) ||| (x >>> (64 - r))) |> mask_64
end
