// https://issues.dlang.org/show_bug.cgi?id=20460

import std.traits : isCallable;

template isCallableWith(alias F, Args...)
{
    enum bool isCallableWith = __traits(compiles, isCallable!(F!Args));
}

class A
{
    void foo(int dat) { }
    void bar()
    {
        alias lambda = (dat) => foo(dat);
        static assert(isCallableWith!(lambda, int));
    }
}

void main() {}
