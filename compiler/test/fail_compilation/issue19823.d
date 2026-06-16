/*
TEST_OUTPUT:
---
fail_compilation/issue19823.d(10): Error: `true` has no effect
---
*/

void main()
{
    __traits(compiles, false);
}
