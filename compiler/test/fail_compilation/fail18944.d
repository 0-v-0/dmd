/*
TEST_OUTPUT:
---
fail_compilation/fail18944.d(17): Error: `writeln` is not defined, perhaps `import std.stdio;` is needed?
fail_compilation/fail18944.d(23): Error: template instance `fail18944.A.opDispatch!"foo"` error instantiating
---
*/

// https://issues.dlang.org/show_bug.cgi?id=18944

void foo(){}

struct A
{
    auto opDispatch(string op)()
    {
        writeln;
    }
}

void test()
{
    A.init.foo();
}
