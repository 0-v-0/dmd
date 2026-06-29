/*
TEST_OUTPUT:
---
fail_compilation/issue19286.d(20): Error: overloads `pure nothrow @nogc @safe int(S2 other)` and `pure nothrow @nogc @safe int(S1 other)` both match argument list for `opBinary`
---
*/

struct S1
{
    int opBinary(string op)(S2 other) { return 3; }
}

struct S2
{
    int opBinaryRight(string op)(S1 other) { return 4; }
}

void main()
{
    auto x = S1.init + S2.init;
}
