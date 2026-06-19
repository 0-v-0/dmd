// https://github.com/dlang/dmd/issues/19574

auto getBits(U, T)(const T value)
if (T.sizeof == U.sizeof && T.alignof >= U.alignof && __traits(isUnsigned, U))
{
    return *cast(U*) &value;
}

void main()
{
    enum ctfeFloatBits = getBits!(uint, float)(1.0f);
    enum ctfeDoubleBits = getBits!(ulong, double)(1.0);
    enum ctfeIFloatBits = getBits!(uint, ifloat)(1.0i);
    enum ctfeIDoubleBits = getBits!(ulong, idouble)(1.0i);
}
