/*
TEST_OUTPUT:
---
fail_compilation/test17849.d(15): Error: function `test17849.S.tmp!((a) => n)` need `this` to access member `tmp`
fail_compilation/test17849.d(12):        called from here: `tmp()`
---
*/

struct S
{
    int n;
    enum t = tmp!(a => n);
}

string tmp(alias T)() { return ""; }
