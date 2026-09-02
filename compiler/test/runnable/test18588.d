/*
TEST_OUTPUT:
---
runnable/test18588.d(24): Deprecation: alias `test18588.CustomTuple(TList...).CustomTuple` is deprecated
alias CustomTuple!(int, 1) MyTuple;
      ^
runnable/test18588.d(20):        `CustomTuple` is declared here
        alias TList CustomTuple;
        ^
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
