defmodule MurmurTest do
  use ExUnit.Case
  import Murmur

  #x86_32

  test "x86_32 empty" do
    assert hash(:x86_32, "") == 0
  end

  test "x86_32 empty with seed 1" do
    assert hash(:x86_32, "", 1) == 1364076727
  end

  test "x86_32 default seed arg" do
    assert hash(:x86_32, "random_stuff") == hash(:x86_32, "random_stuff", 0)
  end

  test "x86_32 0" do
    assert hash(:x86_32, "0") == 3530670207
  end

  test "x86_32 01" do
    assert hash(:x86_32, "01") == 1642882560
  end

  test "x86_32 012" do
    assert hash(:x86_32, "012") == 3966566284
  end

  test "x86_32 0123" do
    assert hash(:x86_32, "0123") == 3558446240
  end

  test "x86_32 01234" do
    assert hash(:x86_32, "01234") == 433070448
  end

  test "x86_32 huge data" do
    assert hash(:x86_32, "b2622f5e1310a0aa14b7f957fe4246fa", 2147368987) == 3297211900
  end

  # x86_128

  test "x86_128 asdfqwer with seed 0" do
    assert hash(:x86_128, "asdfqwer", 0) == 0x790584be55a1e1e58408ecca8408ecca
  end

  test "x86_128 empty" do
    assert hash(:x86_128, "") == 0
  end

  test "x86_128 empty with seed 1" do
    assert hash(:x86_128, "", 1) == 0x88c4adec54d201b954d201b954d201b9
  end

  test "x86_128 default seed arg" do
    assert hash(:x86_128, "random_stuff") == hash(:x86_128, "random_stuff", 0)
  end

  test "x86_128 0" do
    assert hash(:x86_128, "0") == 0x0ab2409ea5eb34f8a5eb34f8a5eb34f8
  end

  test "x86_128 01" do
    assert hash(:x86_128, "01") == 0x0f87acb4674f3b21674f3b21674f3b21
  end

  test "x86_128 012" do
    assert hash(:x86_128, "012") == 0xcd94fea54c13d78e4c13d78e4c13d78e
  end

  test "x86_128 0123" do
    assert hash(:x86_128, "0123") == 0xdc378fea485d3536485d3536485d3536
  end

  test "x86_128 01234" do
    assert hash(:x86_128, "01234") == 0x35c5b3ee7b3b211600ae108800ae1088
  end

  test "x86_128 012345" do
    assert hash(:x86_128, "012345") == 0xdb26dc756ce1944bf825536af825536a
  end

  test "x86_128 huge data" do
    assert hash(:x86_128, "b2622f5e1310a0aa14b7f957fe4246fa", 2147368987) == 0x2435044f7ca7f2cf183e80b51f5fd44c
  end

end
