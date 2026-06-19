/*
REQUIRED_ARGS: -fPIE
DISABLED: win32 win64
*/

// https://github.com/dlang/dmd/issues/19817

immutable int g = 42;

bool foo()
{
    return g == 42 && g != 0;
}

void main()
{
    assert(foo());
}
