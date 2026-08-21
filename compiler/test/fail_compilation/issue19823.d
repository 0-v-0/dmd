// https://issues.dlang.org/show_bug.cgi?id=21395
// Missing source location in: Error: false has no effect
void test()
{
    __traits(compiles);
}
/*
PERMUTE_ARGS:
*/
