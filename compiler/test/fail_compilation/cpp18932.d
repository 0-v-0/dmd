/*
TEST_OUTPUT:
---
fail_compilation/cpp18932.d(12): Error: template instance `cpp18932.foo!(generateEmptyFunction)` C++ template parameter `generateEmptyFunction(C, func...)` is not supported
---
*/

// https://github.com/dlang/dmd/issues/18932

template generateEmptyFunction(C, func...) { enum generateEmptyFunction = ""; }
extern(C++) void foo(alias how)() {}
void main() { foo!generateEmptyFunction(); }
