defmodule Murmur do
  @moduledoc """
  This module implements the x86_32, x86_128 and x64_128 variants of the
  non-cryptographic hash Murmur3.
  """

  use Bitwise

  # murmur constants

  @c1_32  0xcc9e2d51
  @c2_32  0x1b873593
  @n_32   0xe6546b64

  @c1_32_128  0x239b961b
  @c2_32_128  0xab0e9789
  @c3_32_128  0x38b34ae5
  @c4_32_128  0xa1e38b93
  @n1_32_128  0x561ccd1b
  @n2_32_128  0x0bcaa747
  @n3_32_128  0x96cd1c35
  @n4_32_128  0x32ac3b17

  @c1_64_128  0x87c37b91114253d5
  @c2_64_128  0x4cf5ad432745937f
  @n1_64_128  0x52dce729
  @n2_64_128  0x38495ab5

  # since erlang/elixir integers are variable-length we have to guarantee them
  # to be 32 or 64 bit long
  defmacrop mask_32(x), do: quote do: unquote(x) &&& 0xFFFFFFFF
  defmacrop mask_64(x), do: quote do: unquote(x) &&& 0xFFFFFFFFFFFFFFFF

  @doc """
  Returns the hashed erlang `term` using hash variant `type` and the provided `seed`.

  Acceptable hash variants are:
  `:x86_32`, `:x86_128` and `:x64_128`
  """
  @spec hash(atom, term, pos_integer) :: pos_integer
  def hash(type, data, seed \\ 0) do
   case type do
     :x86_32  ->  hash_x86_32(data, seed)
     :x86_128 ->  hash_x86_128(data, seed)
     :x64_128 ->  hash_x64_128(data, seed)
   end
  end

  # x64_128

  @spec hash_x64_128(binary, pos_integer) :: pos_integer
  defp hash_x64_128(data, seed) when is_binary(data) do
    hashes = hash_64_128_aux([seed, seed], data)
    hashes = Enum.zip hashes, [{31, @c1_64_128, @c2_64_128},
                               {33, @c2_64_128, @c1_64_128}]

    hashes = Enum.map hashes, fn ({x, {r, a, b}}) ->
      case x do
        {h, []} -> h ^^^ byte_size(data)
        {h, t}  -> (h ^^^ ((swap_uint(t) * a)
                          |> mask_64 |> rotl64(r) |> Kernel.*(b) |> mask_64))
                    ^^^ byte_size(data)
      end
    end

    [h1, h2] =
      hashes
      |> hash_64_128_intermix
      |> Enum.map(&fmix64/1)
      |> hash_64_128_intermix

    h1 <<< 64 ||| h2
  end

  @spec hash_x64_128(term, pos_integer) :: pos_integer
  defp hash_x64_128(data, seed) do
    hash_x64_128(:erlang.term_to_binary(data), seed)
  end

  # x86_128

  @spec hash_x86_128(binary, pos_integer) :: pos_integer
  defp hash_x86_128(data, seed) when is_binary(data) do
    hashes = hash_32_128_aux([seed, seed, seed, seed], data)
    hashes = Enum.zip hashes, [{15, @c1_32_128, @c2_32_128},
                               {16, @c2_32_128, @c3_32_128},
                               {17, @c3_32_128, @c4_32_128},
                               {18, @c4_32_128, @c1_32_128}]

    hashes = Enum.map hashes, fn ({x, {r, a, b}}) ->
      case x do
        {h, []} -> h ^^^ byte_size(data)
        {h, t}  -> (h ^^^ ((swap_uint(t) * a)
                          |> mask_32 |> rotl32(r) |> Kernel.*(b) |> mask_32))
                    ^^^ byte_size(data)
      end
    end

    [h1, h2, h3, h4] =
      hashes
      |> hash_32_128_intermix
      |> Enum.map(&fmix32/1)
      |> hash_32_128_intermix

    h1 <<< 96 ||| h2 <<< 64 ||| h3 <<< 32 ||| h4
  end

  @spec hash_x86_128(term, pos_integer) :: pos_integer
  defp hash_x86_128(data, seed) do
    hash_x86_128(:erlang.term_to_binary(data), seed)
  end

  # x86_32

  @spec hash_x86_32(binary, pos_integer) :: pos_integer
  defp hash_x86_32(data, seed) when is_binary(data) do
    hash =
      case hash_32_aux(seed, data) do
        {h, []} -> h
        {h, t}  -> h ^^^ ((swap_uint(t) * @c1_32)
                         |> mask_32 |> rotl32(15) |> Kernel.*(@c2_32) |> mask_32)
      end

    fmix32(hash ^^^ byte_size(data))
  end

  @spec hash_x86_32(term, pos_integer) :: pos_integer
  defp hash_x86_32(data, seed) do
    hash_x86_32(:erlang.term_to_binary(data), seed)
  end

  # x64_128 helper functions

  @spec hash_64_128_intermix([pos_integer]) :: [pos_integer]
  defp hash_64_128_intermix([h1, h2]) do
    h1 = (h1 + h2) |> mask_64
    h2 = (h2 + h1) |> mask_64

    [h1, h2]
  end

  @spec hash_64_128_aux([pos_integer], binary) :: [{pos_integer, [binary]}]
  defp hash_64_128_aux([h1, h2],
                      <<k1 :: size(16)-unsigned-little-integer-unit(4),
                        k2 :: size(16)-unsigned-little-integer-unit(4),
                        t  :: binary>>) do
    k1 = mask_64(k1 * @c1_64_128) |> rotl64(31) |> mask_64
          |> Kernel.*(@c2_64_128) |> mask_64
    h1 = (((rotl64(h1 ^^^ k1, 27) + h2) * 5) + @n1_64_128) |> mask_64

    k2 = mask_64(k2 * @c2_64_128) |> rotl64(33) |> mask_64
          |> Kernel.*(@c1_64_128) |> mask_64
    h2 = (((rotl64(h2 ^^^ k2, 31) + h1) * 5) + @n2_64_128) |> mask_64

    hash_64_128_aux([h1, h2], t)
  end

  defp hash_64_128_aux([h1, h2], <<t1 :: size(8)-binary, t :: binary>>) do
    [{h1, t1}, {h2, t}]
  end

  defp hash_64_128_aux([h1, h2], <<t :: binary>>) do
    [{h1, t}, {h2, []}]
  end

  defp hash_64_128_aux([h1, h2], _) do
    [{h1, []}, {h2, []}]
  end

  # x86_128 helper functions

  @spec hash_32_128_intermix([pos_integer]) :: [pos_integer]
  defp hash_32_128_intermix([h1, h2, h3, h4]) do
    h1 = (((((h1 + h2) |> mask_32) + h3) |> mask_32) + h4) |> mask_32
    h2 = (h2 + h1) |> mask_32
    h3 = (h3 + h1) |> mask_32
    h4 = (h4 + h1) |> mask_32

    [h1, h2, h3, h4]
  end

  @spec hash_32_128_aux([pos_integer], binary) :: [{pos_integer, [binary]}]
  defp hash_32_128_aux([h1, h2, h3, h4],
                        <<k1 :: size(8)-unsigned-little-integer-unit(4),
                          k2 :: size(8)-unsigned-little-integer-unit(4),
                          k3 :: size(8)-unsigned-little-integer-unit(4),
                          k4 :: size(8)-unsigned-little-integer-unit(4),
                          t :: binary>>) do
    k1 = mask_32(k1 * @c1_32_128) |> rotl32(15) |> mask_32
          |> Kernel.*(@c2_32_128) |> mask_32
    h1 = (((rotl32(h1 ^^^ k1, 19) + h2) * 5) + @n1_32_128) |> mask_32

    k2 = mask_32(k2 * @c2_32_128) |> rotl32(16) |> mask_32
          |> Kernel.*(@c3_32_128) |> mask_32
    h2 = (((rotl32(h2 ^^^ k2, 17) + h3) * 5) + @n2_32_128) |> mask_32

    k3 = mask_32(k3 * @c3_32_128) |> rotl32(17) |> mask_32
          |> Kernel.*(@c4_32_128) |> mask_32
    h3 = (((rotl32(h3 ^^^ k3, 15) + h4) * 5) + @n3_32_128) |> mask_32

    k4 = mask_32(k4 * @c4_32_128) |> rotl32(18) |> mask_32
          |> Kernel.*(@c1_32_128) |> mask_32
    h4 = (((rotl32(h4 ^^^ k4, 13) + h1) * 5) + @n4_32_128) |> mask_32

    hash_32_128_aux([h1, h2, h3, h4], t)
  end

  defp hash_32_128_aux([h1, h2, h3, h4],
                        <<t1 :: size(4)-binary, t2 :: size(4)-binary,
                          t3 :: size(4)-binary, t  :: binary>>) do
    [{h1, t1}, {h2, t2}, {h3, t3}, {h4, t}]
  end

  defp hash_32_128_aux([h1, h2, h3, h4],
                        <<t1 :: size(4)-binary, t2 :: size(4)-binary,
                          t3 :: binary>>) do
    [{h1, t1}, {h2, t2}, {h3, t3}, {h4, []}]
  end


  defp hash_32_128_aux([h1, h2, h3, h4],
                        <<t1 :: size(4)-binary, t2 :: binary>>) do
    [{h1, t1}, {h2, t2}, {h3, []}, {h4, []}]
  end

  defp hash_32_128_aux([h1, h2, h3, h4], <<t1 :: binary>>) do
    [{h1, t1}, {h2, []}, {h3, []}, {h4, []}]
  end

  defp hash_32_128_aux([h1, h2, h3, h4], _) do
    [{h1, []}, {h2, []}, {h3, []}, {h4, []}]
  end

  # x86_32 helper functions

  @spec hash_32_aux(pos_integer, binary) :: {pos_integer, [binary]}
  defp hash_32_aux(h0, <<k :: size(8)-unsigned-little-integer-unit(4), t :: binary>>) do
    k1 = mask_32(k * @c1_32) |> rotl32(15) |> mask_32 |> Kernel.*(@c2_32) |> mask_32
    (rotl32(h0 ^^^ k1, 13) * 5 + @n_32) |> mask_32 |> hash_32_aux(t)
  end

  defp hash_32_aux(h, t) when byte_size(t) > 0, do: {h, t}
  defp hash_32_aux(h, _), do: {h, []}

  # 32 bit helper functions

  @spec fmix32(pos_integer) :: pos_integer
  defp fmix32(h0) do
    xorbsr(h0, 16) * 0x85ebca6b
    |> mask_32 |> xorbsr(13) |> Kernel.*(0xc2b2ae35) |> mask_32 |> xorbsr(16)
  end

  @spec rotl32(pos_integer, pos_integer) :: pos_integer
  defp rotl32(x, r), do: ((x <<< r) ||| (x >>> (32 - r))) |> mask_32

  # 64bit helper functions

  @spec fmix64(pos_integer) :: pos_integer
  defp fmix64(h0) do
    xorbsr(h0, 33) * 0xff51afd7ed558ccd
    |> mask_64 |> xorbsr(33) |> Kernel.*(0xc4ceb9fe1a85ec53) |> mask_64 |> xorbsr(33)
  end

  @spec rotl64(pos_integer, pos_integer) :: pos_integer
  defp rotl64(x, r), do: ((x <<< r) ||| (x >>> (64 - r))) |> mask_64

  # generic helper functions

  @spec swap_uint(binary) :: pos_integer
  defp swap_uint(<< v1 :: size(8)-unsigned-little-integer,
                      v2 :: size(8)-unsigned-little-integer,
                      v3 :: size(8)-unsigned-little-integer,
                      v4 :: size(8)-unsigned-little-integer,
                      v5 :: size(8)-unsigned-little-integer,
                      v6 :: size(8)-unsigned-little-integer,
                      v7 :: size(8)-unsigned-little-integer,
                      v8 :: size(8)-unsigned-little-integer>>) do
    (((((((v8 <<< 56) ^^^ (v7 <<< 48)) ^^^ (v6 <<< 40)) ^^^ (v5 <<< 32)) ^^^ (v4 <<< 24)) ^^^ (v3 <<< 16)) ^^^ (v2 <<< 8)) ^^^ v1
  end

  defp swap_uint(<< v1 :: size(8)-unsigned-little-integer,
                      v2 :: size(8)-unsigned-little-integer,
                      v3 :: size(8)-unsigned-little-integer,
                      v4 :: size(8)-unsigned-little-integer,
                      v5 :: size(8)-unsigned-little-integer,
                      v6 :: size(8)-unsigned-little-integer,
                      v7 :: size(8)-unsigned-little-integer>>) do
    IO.puts "hi"
    ((((((v7 <<< 48) ^^^ (v6 <<< 40)) ^^^ (v5 <<< 32)) ^^^ (v4 <<< 24)) ^^^ (v3 <<< 16)) ^^^ (v2 <<< 8)) ^^^ v1
  end

  defp swap_uint(<< v1 :: size(8)-unsigned-little-integer,
                      v2 :: size(8)-unsigned-little-integer,
                      v3 :: size(8)-unsigned-little-integer,
                      v4 :: size(8)-unsigned-little-integer,
                      v5 :: size(8)-unsigned-little-integer,
                      v6 :: size(8)-unsigned-little-integer>>) do
    (((((v6 <<< 40) ^^^ (v5 <<< 32)) ^^^ (v4 <<< 24)) ^^^ (v3 <<< 16)) ^^^ (v2 <<< 8)) ^^^ v1
  end

  defp swap_uint(<< v1 :: size(8)-unsigned-little-integer,
                      v2 :: size(8)-unsigned-little-integer,
                      v3 :: size(8)-unsigned-little-integer,
                      v4 :: size(8)-unsigned-little-integer,
                      v5 :: size(8)-unsigned-little-integer>>) do
    ((((v5 <<< 32) ^^^ (v4 <<< 24)) ^^^ (v3 <<< 16)) ^^^ (v2 <<< 8)) ^^^ v1
  end

  defp swap_uint(<< v1 :: size(8)-unsigned-little-integer,
                      v2 :: size(8)-unsigned-little-integer,
                      v3 :: size(8)-unsigned-little-integer,
                      v4 :: size(8)-unsigned-little-integer >>) do
    (((v4 <<< 24) ^^^ (v3 <<< 16)) ^^^ (v2 <<< 8)) ^^^ v1
  end
  defp swap_uint(<< v1 :: size(8)-unsigned-little-integer,
                      v2 :: size(8)-unsigned-little-integer,
                      v3 :: size(8)-unsigned-little-integer >>) do
    ((v3 <<< 16) ^^^ (v2 <<< 8)) ^^^ v1
  end

  defp swap_uint(<< v1 :: size(8)-unsigned-little-integer,
                      v2 :: size(8)-unsigned-little-integer >>) do
    (v2 <<< 8) ^^^ v1
  end

  defp swap_uint(<< v1 :: size(8)-unsigned-little-integer >>) do
    0 ^^^ v1
  end

  defp swap_uint(""), do: 0

  @spec xorbsr(pos_integer, pos_integer) :: pos_integer
  defp xorbsr(h, v), do: h ^^^ (h >>> v)
end
