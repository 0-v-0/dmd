// https://issues.dlang.org/show_bug.cgi?id=24664
// Inconsistent "cannot be used as an lvalue in @safe code" deprecation
// Both indexing through a cast and assigning to a cast should trigger
// the same @safe deprecation.

void main() @safe
{
    int[3] a;
    (cast(uint[3]) a)[0] = 20; // should deprecate
    (cast(uint[3]) a) = [30, 40, 50]; // should deprecate
}
/*
DISABLED_TEST_OUTPUT:
---
exit: 0
---
*/
