/*
REQUIRED_ARGS: -de
TEST_OUTPUT:
---
fail_compilation/deprecate18588.d(17): Deprecation: sequence `TList` is deprecated
fail_compilation/deprecate18588.d(17):        `TList` is declared here
---
*/

template CustomTuple(TList...)
{
    deprecated {
        alias TList CustomTuple;
    }
}

alias CustomTuple!(int, 1) MyTuple;
