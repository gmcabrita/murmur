defmodule MurmurTest do
  use ExUnit.Case
  doctest Murmur
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

  test "x86_32 erlang term" do
    assert hash(:x86_32, :test) == 27149028
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

  test "x86_128 erlang term" do
    assert hash(:x86_128, :test) == 193365738630794791587273517168070843204
  end

  # x64_128

  test "x64_128 0123456 with seed 1000" do
    assert hash(:x64_128, "0123456", 1000) == 0x8e6d1cd3e250da7b42f4bd76d21fe539
  end

  test "x64_128 0123456789 with seed 1000" do
    assert hash(:x64_128, "0123456789", 1000) == 0x72f1651bb10cc77e401a8156169a5cb8
  end

  test "x64_128 asdfqwer with seed 0" do
    assert hash(:x64_128, "asdfqwer", 0) == 0xcb41f064d6d7d367c345e72e8973cd72
  end

  test "x64_128 empty" do
    assert hash(:x64_128, "") == 0
  end

  test "x64_128 empty with seed 1" do
    assert hash(:x64_128, "", 1) == 0x4610abe56eff5cb551622daa78f83583
  end

  test "x64_128 default seed arg" do
    assert hash(:x64_128, "random_stuff") == hash(:x64_128, "random_stuff", 0)
  end

  test "x64_128 0" do
    assert hash(:x64_128, "0") == 0x2ac9debed546a3803a8de9e53c875e09
  end

  test "x64_128 01" do
    assert hash(:x64_128, "01") == 0x649e4eaa7fc1708ee6945110230f2ad6
  end

  test "x64_128 012" do
    assert hash(:x64_128, "012") == 0xce68f60d7c353bdb00364cd5936bf18a
  end

  test "x64_128 0123" do
    assert hash(:x64_128, "0123") == 0x0f95757ce7f38254b4c67c9e6f12ab4b
  end

  test "x64_128 01234" do
    assert hash(:x64_128, "01234") == 0x0f04e459497f3fc1eccc6223a28dd613
  end

  test "x64_128 012345" do
    assert hash(:x64_128, "012345") == 0x88c0a92586be0a2781062d6137728244
  end

  test "x64_128 huge data" do
    assert hash(:x64_128, "b2622f5e1310a0aa14b7f957fe4246fa", 2147368987) == 0xf982047579beb692f57653a0620f950b
  end

  test "x64_128 erlang term" do
    assert hash(:x64_128, :test) == 261489243741046697889268700172115018588
  end
end
