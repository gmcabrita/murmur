defmodule MurmurexTest do
  use ExUnit.Case
  import Murmurex

  test "hash_x86_32 empty" do
    assert hash_x86_32("") == 0
  end

  test "hash_x86_32 empty with seed 1" do
    assert hash_x86_32("", 1) == 1364076727
  end

  test "hash_x86_32 default seed arg" do
    assert hash_x86_32("random_stuff") == hash_x86_32("random_stuff", 0)
  end

  test "hash_x86_32 0" do
    assert hash_x86_32("0") == 3530670207
  end

  test "hash_x86_32 01" do
    assert hash_x86_32("01") == 1642882560
  end

  test "hash_x86_32 012" do
    assert hash_x86_32("012") == 3966566284
  end

  test "hash_x86_32 0123" do
    assert hash_x86_32("0123") == 3558446240
  end

  test "hash_x86_32 01234" do
    assert hash_x86_32("01234") == 433070448
  end

  test "hash_x86_32 huge data" do
    assert hash_x86_32("b2622f5e1310a0aa14b7f957fe4246fa", 2147368987) == 3297211900
  end
end
