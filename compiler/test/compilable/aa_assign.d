// https://issues.dlang.org/show_bug.cgi?id=17648

void test_mutable_key()
{
    int[char[]] aa;
    char[] str = "123".dup;
    aa[str] = 3;
    assert(str in aa);
}
