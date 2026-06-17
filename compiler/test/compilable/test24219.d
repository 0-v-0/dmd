// https://issues.dlang.org/show_bug.cgi?id=24219

struct S
{
    int x, y;
}

void main()
{
    auto s1 = S(123, 456);
    auto s2 = S(123, 456);
    assert(s1.tupleof is s2.tupleof);
}
