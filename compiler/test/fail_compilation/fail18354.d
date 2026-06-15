/*
TEST_OUTPUT:
---
fail_compilation/fail18354.d(6): Error: function `fail18354.B.foo` cannot override method `fail18354.A.foo` with `@property` method `fail18354.B.foo`
fail_compilation/fail18354.d(7): Error: function `fail18354.B.bar` cannot override `@property` method `fail18354.A.bar` with method `fail18354.B.bar`
---
*/

class A
{
    int foo();
    @property int bar();
}

class B : A
{
    @property override int foo();
    override int bar();
}
