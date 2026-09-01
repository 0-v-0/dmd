/* TEST_OUTPUT:
---
fail_compilation/issue18354.d(13): Error: function `issue18354.B.foo` cannot override non-`@property` method `issue18354.A.foo` with a `@property` attribute
fail_compilation/issue18354.d(14): Error: function `issue18354.B.bar` cannot override `@property` method `issue18354.A.bar` with a non-`@property` attribute
---
*/

class A {
    int foo() { return 0; }
    @property int bar() { return 0; }
}
class B : A {
    @property override int foo() { return 0; }
    override int bar() { return 0; }
}

