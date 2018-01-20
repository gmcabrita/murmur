defmodule MurmurTest do
  use ExUnit.Case
  doctest Murmur
  import Murmur

  # x86_32

  test "x86_32 empty" do
    assert hash_x86_32("") == 0
  end

  test "x86_32 empty with seed 1" do
    assert hash_x86_32("", 1) == 1_364_076_727
  end

  test "x86_32 default seed arg" do
    assert hash_x86_32("random_stuff") == hash_x86_32("random_stuff", 0)
  end

  test "x86_32 0" do
    assert hash_x86_32("0") == 3_530_670_207
  end

  test "x86_32 01" do
    assert hash_x86_32("01") == 1_642_882_560
  end

  test "x86_32 012" do
    assert hash_x86_32("012") == 3_966_566_284
  end

  test "x86_32 0123" do
    assert hash_x86_32("0123") == 3_558_446_240
  end

  test "x86_32 01234" do
    assert hash_x86_32("01234") == 433_070_448
  end

  test "x86_32 huge data" do
    assert hash_x86_32("b2622f5e1310a0aa14b7f957fe4246fa", 2_147_368_987) == 3_297_211_900
  end

  test "x86_32 erlang term" do
    assert hash_x86_32(:test) == 27_149_028
  end

  # x86_128

  test "x86_128 asdfqwer with seed 0" do
    assert hash_x86_128("asdfqwer", 0) == 0x790584BE55A1E1E58408ECCA8408ECCA
  end

  test "x86_128 empty" do
    assert hash_x86_128("") == 0
  end

  test "x86_128 empty with seed 1" do
    assert hash_x86_128("", 1) == 0x88C4ADEC54D201B954D201B954D201B9
  end

  test "x86_128 default seed arg" do
    assert hash_x86_128("random_stuff") == hash_x86_128("random_stuff", 0)
  end

  test "x86_128 0" do
    assert hash_x86_128("0") == 0x0AB2409EA5EB34F8A5EB34F8A5EB34F8
  end

  test "x86_128 01" do
    assert hash_x86_128("01") == 0x0F87ACB4674F3B21674F3B21674F3B21
  end

  test "x86_128 012" do
    assert hash_x86_128("012") == 0xCD94FEA54C13D78E4C13D78E4C13D78E
  end

  test "x86_128 0123" do
    assert hash_x86_128("0123") == 0xDC378FEA485D3536485D3536485D3536
  end

  test "x86_128 01234" do
    assert hash_x86_128("01234") == 0x35C5B3EE7B3B211600AE108800AE1088
  end

  test "x86_128 012345" do
    assert hash_x86_128("012345") == 0xDB26DC756CE1944BF825536AF825536A
  end

  test "x86_128 huge data" do
    assert hash_x86_128("b2622f5e1310a0aa14b7f957fe4246fa", 2_147_368_987) ==
             0x2435044F7CA7F2CF183E80B51F5FD44C
  end

  test "x86_128 erlang term" do
    assert hash_x86_128(:test) == 193_365_738_630_794_791_587_273_517_168_070_843_204
  end

  # x64_128

  test "x64_128 0123456 with seed 1000" do
    assert hash_x64_128("0123456", 1000) == 0x8E6D1CD3E250DA7B42F4BD76D21FE539
  end

  test "x64_128 0123456789 with seed 1000" do
    assert hash_x64_128("0123456789", 1000) == 0x72F1651BB10CC77E401A8156169A5CB8
  end

  test "x64_128 asdfqwer with seed 0" do
    assert hash_x64_128("asdfqwer", 0) == 0xCB41F064D6D7D367C345E72E8973CD72
  end

  test "x64_128 empty" do
    assert hash_x64_128("") == 0
  end

  test "x64_128 empty with seed 1" do
    assert hash_x64_128("", 1) == 0x4610ABE56EFF5CB551622DAA78F83583
  end

  test "x64_128 default seed arg" do
    assert hash_x64_128("random_stuff") == hash_x64_128("random_stuff", 0)
  end

  test "x64_128 0" do
    assert hash_x64_128("0") == 0x2AC9DEBED546A3803A8DE9E53C875E09
  end

  test "x64_128 01" do
    assert hash_x64_128("01") == 0x649E4EAA7FC1708EE6945110230F2AD6
  end

  test "x64_128 012" do
    assert hash_x64_128("012") == 0xCE68F60D7C353BDB00364CD5936BF18A
  end

  test "x64_128 0123" do
    assert hash_x64_128("0123") == 0x0F95757CE7F38254B4C67C9E6F12AB4B
  end

  test "x64_128 01234" do
    assert hash_x64_128("01234") == 0x0F04E459497F3FC1ECCC6223A28DD613
  end

  test "x64_128 012345" do
    assert hash_x64_128("012345") == 0x88C0A92586BE0A2781062D6137728244
  end

  test "x64_128 huge data" do
    assert hash_x64_128("b2622f5e1310a0aa14b7f957fe4246fa", 2_147_368_987) ==
             0xF982047579BEB692F57653A0620F950B
  end

  test "x64_128 erlang term" do
    assert hash_x64_128(:test) == 261_489_243_741_046_697_889_268_700_172_115_018_588
  end
end
