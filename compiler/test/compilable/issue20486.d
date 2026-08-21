// https://issues.dlang.org/show_bug.cgi?id=24664
// Inconsistent "cannot be used as an lvalue in @safe code" deprecation:
// both assigning TO a cast and indexing THROUGH a cast should be deprecated.
/*
REQUIRED_ARGS: -verrors=simple
TEST_OUTPUT:
---
compilable/issue20486.d(16): Deprecation: using the result of a cast from `int[3]` to `uint[3]` as an lvalue will become `@system` in a future release
compilable/issue20486.d(17): Deprecation: using the result of a cast from `int[3]` to `uint[3]` as an lvalue will become `@system` in a future release
---
*/

void main() @safe
{
    int[3] a;
    (cast(uint[3]) a)[0] = 20;
    (cast(uint[3]) a) = [30, 40, 50];
}
