/*
TEST_OUTPUT:
---
fail_compilation/test17849.d(6): Error: function `test17849.S.tmp!((a) => n).tmp` need `this` to access member `n`
fail_compilation/test17849.d(3):        called from here: `tmp()`
---
*/

struct S
{
    int n;
    enum t = tmp!(a => n);
}

string tmp(alias T)() { return ""; }
