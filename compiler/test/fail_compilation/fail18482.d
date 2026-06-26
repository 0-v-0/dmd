/*
TEST_OUTPUT:
---
 fail_compilation/fail18482.d(19): Error: cannot modify expression `S()` because it is not an lvalue
 fail_compilation/fail18482.d(20): Error: cannot modify expression `sFunc()` because it is not an lvalue
---
*/

struct S
{
    void opUnary(string op : "++")() {}
    void opAssign(int) {}
}

S sFunc() { return S(); }

void main()
{
    ++S.init;
    ++sFunc();
    S.init = 3;
    sFunc() = 3;
}
