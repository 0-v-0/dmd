// https://issues.dlang.org/show_bug.cgi?id=21395
// Missing source location in: Error: false has no effect
void test()
{
    __traits(compiles);
}
/*
TEST_OUTPUT:
---
fail_compilation/issue19823.d(5): Error: `false` has no effect
---
PERMUTE_ARGS:
*/
