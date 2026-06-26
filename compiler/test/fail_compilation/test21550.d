/*
TEST_OUTPUT:
---
fail_compilation/test21550.d(17): Error: function `test21550.f` cannot be used because it is annotated with `@disable("because")`
    f();
     ^
---
*/
module test21550;

@disable("because") void f()
{
}

void main()
{
    f();
}
