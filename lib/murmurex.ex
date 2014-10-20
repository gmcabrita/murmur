defmodule Murmurex do
  @moduledoc """
  This module implements the x86_32, x86_128 and x64_128 variants of the
  non-cryptographic hash Murmur3.
  """

  use Bitwise

  @c1_32  0xcc9e2d51
  @c2_32  0x1b873593
  @n_32   0xe6546b64

  defmacrop mask_32(x), do: quote do: unquote(x) &&& 0xFFFFFFFF
  defmacrop mask_64(x), do: quote do: unquote(x) &&& 0xFFFFFFFFFFFFFFFF

  @spec hash_x86_32(term) :: pos_integer
  def hash_x86_32(data) do
    hash_x86_32(data, 0)
  end

  @spec hash_x86_32(binary, pos_integer) :: pos_integer
  def hash_x86_32(data, seed) when is_binary(data) do
    hash =
      case hash_32_aux(seed, data) do
        {h, []} -> h
        {h, t}  -> h ^^^ ((swap_uint32(t) * @c1_32)
                         |> mask_32 |> rotl32(15) |> Kernel.*(@c2_32) |> mask_32)
      end

    fmix32(hash ^^^ byte_size(data))
  end

  @spec hash_x86_32(term, pos_integer) :: pos_integer
  def hash_x86_32(data, seed) do
    hash_x86_32(:erlang.term_to_binary(data), seed)
  end

  defp hash_32_aux(h0, <<k :: size(8)-unsigned-little-integer-unit(4), t :: binary>>) do
    k1 = mask_32(k * @c1_32) |> rotl32(15) |> mask_32 |> Kernel.*(@c2_32) |> mask_32
    (rotl32(h0 ^^^ k1, 13) * 5 + @n_32) |> mask_32 |> hash_32_aux(t)
  end

  defp hash_32_aux(h, t) when byte_size(t) > 0, do: {h, t}
  defp hash_32_aux(h, _), do: {h, []}

  defp fmix32(h0) do
    xorbsr(h0, 16) * 0x85ebca6b
    |> mask_32 |> xorbsr(13) |> Kernel.*(0xc2b2ae35) |> mask_32 |> xorbsr(16)
  end

  defp fmix64(h0) do
    xorbsr(h0, 33) * 0xff51afd7ed558ccd
    |> mask_64 |> xorbsr(33) |> Kernel.*(0xc4ceb9fe1a85ec53) |> mask_64 |> xorbsr(33)
  end

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

  defp xorbsr(h, v), do: h ^^^ (h >>> v)
  defp rotl32(x, r), do: ((x <<< r) ||| (x >>> (32 - r))) |> mask_32
  defp rotl64(x, r), do: ((x <<< r) ||| (x >>> (64 - r))) |> mask_64
end
