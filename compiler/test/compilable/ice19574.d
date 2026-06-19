auto getBits(U, T)(const T value)
if (T.sizeof == U.sizeof && T.alignof >= U.alignof && __traits(isUnsigned, U))
{
    return *cast(U*)&value;
}

void main()
{
    enum ctfeIFloatBits = getBits!(uint, ifloat)(1.0i);
    enum ctfeIDoubleBits = getBits!(ulong, idouble)(1.0i);
}
