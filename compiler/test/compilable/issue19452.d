// https://github.com/dlang/dmd/issues/19452

void main()
{
    real r = 10;
    bool b = cast(ulong) r == 0;
}
