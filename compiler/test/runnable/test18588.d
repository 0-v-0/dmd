/*
TEST_OUTPUT:
---
DEPRECATION: alias `test18588.CustomTuple(TList...).CustomTuple` is deprecated
---
*/

// https://issues.dlang.org/show_bug.cgi?id=18588
// deprecated should be reported when used inside a template

template CustomTuple(TList...)
{
    deprecated
    {
        alias TList CustomTuple;
    }
}

alias CustomTuple!(int, 1) MyTuple;

void main()
{
}
