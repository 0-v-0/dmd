/*
REQUIRED_ARGS: -preview=dip1000 -de
TEST_OUTPUT:
---
fail_compilation/cast_qual.d(19): Deprecation: using the result of a cast from `const(int)` to `int` as an lvalue will become `@system` in a future release
fail_compilation/cast_qual.d(21): Deprecation: using the result of a cast from `const(int)` to `int` as an lvalue will become `@system` in a future release
fail_compilation/cast_qual.d(27): Error: cast from `const(Object)` to `object.Object` is not allowed in a `@safe` function
fail_compilation/cast_qual.d(27):        Incompatible type qualifier
fail_compilation/cast_qual.d(32): Deprecation: using the result of a cast from `int[3]` to `uint[3]` as an lvalue will become `@system` in a future release
fail_compilation/cast_qual.d(33): Deprecation: using the result of a cast from `int[3]` to `uint[3]` as an lvalue will become `@system` in a future release
---
*/

@safe:

void main() {
    const int i = 3;
    int j = cast() i; // OK
    int* p = &cast() i; // this should not compile in @safe code
    *p = 4; // oops
    cast() i = 5; // NG
    auto q = &cast(const) j; // OK, int* to const int*
}

void test() {
    const Object co;
    auto o = cast() co;
}

void testArray() @safe {
    int[3] a;
    (cast(uint[3]) a)[0] = 20; // should match the whole-cast lvalue diagnostic
    (cast(uint[3]) a) = [30, 40, 50];
}
