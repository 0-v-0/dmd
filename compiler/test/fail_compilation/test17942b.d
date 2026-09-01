// https://issues.dlang.org/show_bug.cgi?id=17942
// A string-typed expression (from an enum) must not implicitly convert to
// dstring. Only uncommitted (polysemous) string literals may do so.

struct VariableDefinition {
    string lex;
}

enum LOCALVARS = [
    VariableDefinition("#1"),
];

enum ENUMSTR = "abc";

void foo(dstring s) {
}

void main() {
    foo(LOCALVARS[0].lex); // string -> dstring, should fail
    foo(ENUMSTR);           // string -> dstring, should fail
}

/*
TEST_OUTPUT:
---
fail_compilation/test17942b.d(19): Error: function `foo` is not callable using argument types `(string)`
fail_compilation/test17942b.d(20): Error: function `foo` is not callable using argument types `(string)`
---
*/
