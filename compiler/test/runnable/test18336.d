/*
 * Test for issue 18336: Template specialization ordering bug
 * https://issues.dlang.org/show_bug.cgi?id=18336
 *
 * When a template has a default parameter (U = int) that is not part of
 * any specialization pattern, the specialization ordering should not
 * report false ambiguity.
 */

struct Foo(T) {}
struct Foo(T : Bar!R, U = int, R) {}
struct Bar(R) {}

Foo!(Bar!float) f;

// Also test with multiple defaulted params
struct Foo2(T) {}
struct Foo2(T : Bar!R, U = int, V = string, R) {}
Foo2!(Bar!float) f2;

// Test without the default param (was already working)
struct Foo3(T) {}
struct Foo3(T : Bar!R, R) {}
Foo3!(Bar!float) f3;

void main() {}
