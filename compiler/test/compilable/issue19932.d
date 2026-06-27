// https://issues.dlang.org/show_bug.cgi?id=19932

/*
TEST_OUTPUT:
---
compiler/test/compilable/issue19932.d(10): Deprecation: use of imaginary type `const(ifloat)` is deprecated, use `float` instead
compiler/test/compilable/issue19932.d(10): Deprecation: use of imaginary type `const(idouble)` is deprecated, use `double` instead
---
*/
auto getBits(U, T)(const T value)
if (T.sizeof == U.sizeof && T.alignof >= U.alignof && __traits(isUnsigned, U))
{
    return *cast(U*) &value;
}

enum floatBits = getBits!(uint, float)(1.0f);
enum doubleBits = getBits!(ulong, double)(1.0);
enum ifloatBits = getBits!(uint, ifloat)(1.0i);
enum idoubleBits = getBits!(ulong, idouble)(1.0i);

static assert(floatBits == 0x3F800000u);
static assert(doubleBits == 0x3FF0000000000000UL);
static assert(ifloatBits == 0x3F800000u);
static assert(idoubleBits == 0x3FF0000000000000UL);
