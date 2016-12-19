defmodule Murmur do
  @moduledoc ~S"""
  This module implements the x86_32, x86_128 and x64_128 variants of the
  non-cryptographic hash Murmur3.

  ## Examples

      iex> Murmur.hash_x86_32("b2622f5e1310a0aa14b7f957fe4246fa", 2147368987)
      3297211900

      iex> Murmur.hash_x86_128("some random data")
      5586633072055552000169173700229798482

      iex> Murmur.hash_x64_128([:yes, :you, :can, :use, :any, :erlang, :term!])
      300414073828138369336317731503972665325

  """

  use Bitwise

  # murmur constants

  @c1_32 0xcc9e2d51
  @c2_32 0x1b873593
  @n_32  0xe6546b64

  @c1_32_128 0x239b961b
  @c2_32_128 0xab0e9789
  @c3_32_128 0x38b34ae5
  @c4_32_128 0xa1e38b93
  @n1_32_128 0x561ccd1b
  @n2_32_128 0x0bcaa747
  @n3_32_128 0x96cd1c35
  @n4_32_128 0x32ac3b17

  @c1_64_128 0x87c37b91114253d5
  @c2_64_128 0x4cf5ad432745937f
  @n1_64_128 0x52dce729
  @n2_64_128 0x38495ab5

  # since erlang/elixir integers are variable-length we have to guarantee them
  # to be 32 or 64 bit long
  defmacrop mask_32(x), do: quote do: unquote(x) &&& 0xFFFFFFFF
  defmacrop mask_64(x), do: quote do: unquote(x) &&& 0xFFFFFFFFFFFFFFFF

  @doc """
  Returns the hashed erlang term `data` using an optional `seed` which defaults to `0`.

  This function uses the x64 128bit variant.
  """
  @spec hash_x64_128(binary | term, non_neg_integer) :: non_neg_integer
  def hash_x64_128(data, seed \\ 0)
  def hash_x64_128(data, seed) when is_binary(data) do
    hashes =
      [seed, seed]
      |> hash_64_128_aux(data)
      |> Stream.zip([
        {31, @c1_64_128, @c2_64_128},
        {33, @c2_64_128, @c1_64_128}
      ])
      |> Stream.map(
        fn ({x, {r, a, b}}) ->
          case x do
            {h, []} -> h ^^^ byte_size(data)
            {h, t}  -> (h ^^^ (t
                               |> swap_uint()
                               |> Kernel.*(a)
                               |> mask_64
                               |> rotl64(r)
                               |> Kernel.*(b)
                               |> mask_64))
                       ^^^ byte_size(data)
          end
        end)
      |> Enum.to_list

    [h1, h2] =
      hashes
      |> hash_64_128_intermix
      |> Enum.map(&fmix64/1)
      |> hash_64_128_intermix

    h1 <<< 64 ||| h2
  end

  def hash_x64_128(data, seed) do
    hash_x64_128(:erlang.term_to_binary(data), seed)
  end

  @doc """
  Returns the hashed erlang term `data` using an optional `seed` which defaults to `0`.

  This function uses the x86 128bit variant.
  """
  @spec hash_x86_128(binary | term, non_neg_integer) :: non_neg_integer
  def hash_x86_128(data, seed \\ 0)
  def hash_x86_128(data, seed) when is_binary(data) do
    hashes =
      [seed, seed, seed, seed]
      |> hash_32_128_aux(data)
      |> Stream.zip([
        {15, @c1_32_128, @c2_32_128},
        {16, @c2_32_128, @c3_32_128},
        {17, @c3_32_128, @c4_32_128},
        {18, @c4_32_128, @c1_32_128}
      ])
      |> Stream.map(
        fn ({x, {r, a, b}}) ->
          case x do
            {h, []} -> h ^^^ byte_size(data)
            {h, t}  -> (h ^^^ (t
                               |> swap_uint()
                               |> Kernel.*(a)
                               |> mask_32
                               |> rotl32(r)
                               |> Kernel.*(b)
                               |> mask_32))
                       ^^^ byte_size(data)
          end
        end)
      |> Enum.to_list

    [h1, h2, h3, h4] =
      hashes
      |> hash_32_128_intermix
      |> Enum.map(&fmix32/1)
      |> hash_32_128_intermix

    h1 <<< 96 ||| h2 <<< 64 ||| h3 <<< 32 ||| h4
  end

  def hash_x86_128(data, seed) do
    hash_x86_128(:erlang.term_to_binary(data), seed)
  end

  @doc """
  Returns the hashed erlang term `data` using an optional `seed` which defaults to `0`.

  This function uses the x86 32bit variant.
  """
  @spec hash_x86_32(binary | term, non_neg_integer) :: non_neg_integer
  def hash_x86_32(data, seed \\ 0)
  def hash_x86_32(data, seed) when is_binary(data) do
    hash =
      case hash_32_aux(seed, data) do
        {h, []} -> h
        {h, t}  -> h ^^^ (t
                          |> swap_uint()
                          |> Kernel.*(@c1_32)
                          |> mask_32
                          |> rotl32(15)
                          |> Kernel.*(@c2_32)
                          |> mask_32)
      end

    fmix32(hash ^^^ byte_size(data))
  end

  def hash_x86_32(data, seed) do
    hash_x86_32(:erlang.term_to_binary(data), seed)
  end

  # x64_128 helper functions

  @spec hash_64_128_intermix([non_neg_integer]) :: [non_neg_integer]
  defp hash_64_128_intermix([h1, h2]) do
    h1 = mask_64(h1 + h2)
    h2 = mask_64(h2 + h1)

    [h1, h2]
  end

  @spec k_64_op(non_neg_integer,
                non_neg_integer,
                non_neg_integer,
                non_neg_integer) :: non_neg_integer
  defp k_64_op(k, c1, rotl, c2) do
    k
    |> Kernel.*(c1)
    |> mask_64
    |> rotl64(rotl)
    |> mask_64
    |> Kernel.*(c2)
    |> mask_64
  end

  @spec h_64_op(non_neg_integer,
                non_neg_integer,
                non_neg_integer,
                non_neg_integer,
                non_neg_integer,
                non_neg_integer) :: non_neg_integer
  defp h_64_op(h1, k, rotl, h2, const, n) do
    h1
    |> Bitwise.^^^(k)
    |> rotl64(rotl)
    |> Kernel.+(h2)
    |> Kernel.*(const)
    |> Kernel.+(n)
    |> mask_64
  end

  @spec hash_64_128_aux([non_neg_integer], binary) :: [{non_neg_integer, [binary]}]
  defp hash_64_128_aux([h1, h2],
                       <<k1::size(16) - little - unit(4),
                         k2::size(16) - little - unit(4),
                          t::binary>>) do
    k1 = k_64_op(k1, @c1_64_128, 31, @c2_64_128)
    h1 = h_64_op(h1, k1, 27, h2, 5, @n1_64_128)

    k2 = k_64_op(k2, @c2_64_128, 33, @c1_64_128)
    h2 = h_64_op(h2, k2, 31, h1, 5, @n2_64_128)

    hash_64_128_aux([h1, h2], t)
  end

  defp hash_64_128_aux([h1, h2], <<t1 :: size(8)-binary, t :: binary>>) do
    [{h1, t1}, {h2, t}]
  end

  defp hash_64_128_aux([h1, h2], t) when is_binary(t) do
    [{h1, t}, {h2, []}]
  end

  defp hash_64_128_aux([h1, h2], _) do
    [{h1, []}, {h2, []}]
  end

  # x86_128 helper functions

  @spec hash_32_128_intermix([non_neg_integer]) :: [non_neg_integer]
  defp hash_32_128_intermix([h1, h2, h3, h4]) do
    h1 =
      h1
      |> Kernel.+(h2)
      |> mask_32
      |> Kernel.+(h3)
      |> mask_32
      |> Kernel.+(h4)
      |> mask_32

    h2 = mask_32(h2 + h1)
    h3 = mask_32(h3 + h1)
    h4 = mask_32(h4 + h1)

    [h1, h2, h3, h4]
  end

  @spec k_32_op(non_neg_integer,
                non_neg_integer,
                non_neg_integer,
                non_neg_integer) :: non_neg_integer
  defp k_32_op(k, c1, rotl, c2) do
    k
    |> Kernel.*(c1)
    |> mask_32
    |> rotl32(rotl)
    |> mask_32
    |> Kernel.*(c2)
    |> mask_32
  end

  @spec h_32_op(non_neg_integer,
                non_neg_integer,
                non_neg_integer,
                non_neg_integer,
                non_neg_integer,
                non_neg_integer) :: non_neg_integer
  defp h_32_op(h1, k, rotl, h2, const, n) do
    h1
    |> Bitwise.^^^(k)
    |> rotl32(rotl)
    |> Kernel.+(h2)
    |> Kernel.*(const)
    |> Kernel.+(n)
    |> mask_32
  end

  @spec hash_32_128_aux([non_neg_integer], binary) :: [{non_neg_integer, [binary]}]
  defp hash_32_128_aux([h1, h2, h3, h4],
                       <<k1::size(8) - little - unit(4),
                         k2::size(8) - little - unit(4),
                         k3::size(8) - little - unit(4),
                         k4::size(8) - little - unit(4),
                          t::binary>>) do
    k1 = k_32_op(k1, @c1_32_128, 15, @c2_32_128)
    h1 = h_32_op(h1, k1, 19, h2, 5, @n1_32_128)

    k2 = k_32_op(k2, @c2_32_128, 16, @c3_32_128)
    h2 = h_32_op(h2, k2, 17, h3, 5, @n2_32_128)

    k3 = k_32_op(k3, @c3_32_128, 17, @c4_32_128)
    h3 = h_32_op(h3, k3, 15, h4, 5, @n3_32_128)

    k4 = k_32_op(k4, @c4_32_128, 18, @c1_32_128)
    h4 = h_32_op(h4, k4, 13, h1, 5, @n4_32_128)

    hash_32_128_aux([h1, h2, h3, h4], t)
  end

  defp hash_32_128_aux([h1, h2, h3, h4],
                       <<t1 :: size(4)-binary,
                         t2 :: size(4)-binary,
                         t3 :: size(4)-binary,
                         t  :: binary>>) do
    [{h1, t1}, {h2, t2}, {h3, t3}, {h4, t}]
  end

  defp hash_32_128_aux([h1, h2, h3, h4],
                       <<t1 :: size(4)-binary,
                         t2 :: size(4)-binary,
                         t3 :: binary>>) do
    [{h1, t1}, {h2, t2}, {h3, t3}, {h4, []}]
  end


  defp hash_32_128_aux([h1, h2, h3, h4], <<t1 :: size(4)-binary, t2 :: binary>>) do
    [{h1, t1}, {h2, t2}, {h3, []}, {h4, []}]
  end

  defp hash_32_128_aux([h1, h2, h3, h4], t1) when is_binary(t1) do
    [{h1, t1}, {h2, []}, {h3, []}, {h4, []}]
  end

  defp hash_32_128_aux([h1, h2, h3, h4], _) do
    [{h1, []}, {h2, []}, {h3, []}, {h4, []}]
  end

  # x86_32 helper functions

  @spec hash_32_aux(non_neg_integer, binary) :: {non_neg_integer, [binary] | binary}
  defp hash_32_aux(h0, <<k :: size(8)-little-unit(4), t :: binary>>) do
    k1 = k_32_op(k, @c1_32, 15, @c2_32)

    h0
    |> Bitwise.^^^(k1)
    |> rotl32(13)
    |> Kernel.*(5)
    |> Kernel.+(@n_32)
    |> mask_32
    |> hash_32_aux(t)
  end

  defp hash_32_aux(h, t) when byte_size(t) > 0, do: {h, t}
  defp hash_32_aux(h, _), do: {h, []}

  # 32 bit helper functions

  @spec fmix32(non_neg_integer) :: non_neg_integer
  defp fmix32(h0) do
    h0
    |> xorbsr(16)
    |> Kernel.*(0x85ebca6b)
    |> mask_32
    |> xorbsr(13)
    |> Kernel.*(0xc2b2ae35)
    |> mask_32
    |> xorbsr(16)
  end

  @spec rotl32(non_neg_integer, non_neg_integer) :: non_neg_integer
  defp rotl32(x, r), do: mask_32((x <<< r) ||| (x >>> (32 - r)))

  # 64bit helper functions

  @spec fmix64(non_neg_integer) :: non_neg_integer
  defp fmix64(h0) do
    h0
    |> xorbsr(33)
    |> Kernel.*(0xff51afd7ed558ccd)
    |> mask_64
    |> xorbsr(33)
    |> Kernel.*(0xc4ceb9fe1a85ec53)
    |> mask_64
    |> xorbsr(33)
  end

  @spec rotl64(non_neg_integer, non_neg_integer) :: non_neg_integer
  defp rotl64(x, r), do: mask_64((x <<< r) ||| (x >>> (64 - r)))

  # generic helper functions

  @spec swap_uint(binary) :: non_neg_integer
  defp swap_uint(<<v1::size(8), v2::size(8), v3::size(8), v4::size(8),
                   v5::size(8), v6::size(8), v7::size(8), v8::size(8)>>) do
    (((((((v8 <<< 56) ^^^ (v7 <<< 48)) ^^^ (v6 <<< 40)) ^^^ (v5 <<< 32)) ^^^ (v4 <<< 24)) ^^^ (v3 <<< 16)) ^^^ (v2 <<< 8)) ^^^ v1
  end

  defp swap_uint(<<v1::size(8), v2::size(8), v3::size(8), v4::size(8),
                   v5::size(8), v6::size(8), v7::size(8)>>) do
    ((((((v7 <<< 48) ^^^ (v6 <<< 40)) ^^^ (v5 <<< 32)) ^^^ (v4 <<< 24)) ^^^ (v3 <<< 16)) ^^^ (v2 <<< 8)) ^^^ v1
  end

  defp swap_uint(<<v1::size(8), v2::size(8), v3::size(8), v4::size(8),
                   v5::size(8), v6::size(8)>>) do
    (((((v6 <<< 40) ^^^ (v5 <<< 32)) ^^^ (v4 <<< 24)) ^^^ (v3 <<< 16)) ^^^ (v2 <<< 8)) ^^^ v1
  end

  defp swap_uint(<<v1::size(8), v2::size(8), v3::size(8), v4::size(8),
                   v5::size(8)>>) do
    ((((v5 <<< 32) ^^^ (v4 <<< 24)) ^^^ (v3 <<< 16)) ^^^ (v2 <<< 8)) ^^^ v1
  end

  defp swap_uint(<<v1::size(8), v2::size(8), v3::size(8), v4::size(8)>>) do
    (((v4 <<< 24) ^^^ (v3 <<< 16)) ^^^ (v2 <<< 8)) ^^^ v1
  end
  defp swap_uint(<<v1::size(8), v2::size(8), v3::size(8)>>) do
    ((v3 <<< 16) ^^^ (v2 <<< 8)) ^^^ v1
  end

  defp swap_uint(<<v1::size(8), v2::size(8)>>) do
    (v2 <<< 8) ^^^ v1
  end

  defp swap_uint(<<v1::size(8)>>) do
    0 ^^^ v1
  end

  defp swap_uint(""), do: 0

  @spec xorbsr(non_neg_integer, non_neg_integer) :: non_neg_integer
  defp xorbsr(h, v), do: h ^^^ (h >>> v)
end
