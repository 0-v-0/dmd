// https://issues.dlang.org/show_bug.cgi?id=18657

module test18657;

import std.typetuple : Reverse;

template CurryDefVal(alias Call, DefVals...)
{
    static if (is(typeof(CurryDefValImpl1!(Call, DefVals))))
    {
        alias CurryDefValImpl1!(Call, DefVals) CurryDefVal;
    }
    else
    {
        alias CurryDefValImpl2!(Call, DefVals) CurryDefVal;
    }
}

void test()
{
    static void foo(int x, float y, string z)
    {
    }

    alias CurryDefVal!(foo, "a", 1.0, 1) fooDef3;
    alias CurryDefVal!(foo, "a", 1.0) fooDef2;
    alias CurryDefVal!(foo, "a") fooDef1;
    alias CurryDefVal!(foo) fooDef0;
    alias CurryDefVal!(fooDef1, 2.0, 3) fooDef3_clone;

    fooDef0(1, 1.0, "a");
    fooDef1(1, 1.0);
    fooDef2(1);
    fooDef3();
    fooDef3_clone();

    static void testMe(ref int y)
    {
        if (y == 10)
            return;

        alias CurryDefVal!(testMe, y) recurse;

        y = 10;
        recurse();
    }

    int x;
    testMe(x);
}

template CurryDefValImpl1(alias Call, DefVals...)
    if (isCallable!Call && DefVals.length <= ParameterTypeTuple!Call.length)
{
    auto CurryDefValImpl1(T...)(T args)
    {
        return Call(args, Reverse!DefVals);
    }
}

struct CurryDefValImpl2(alias Call, DefVals...)
{
    static auto opCall(T...)(T args)
    {
        return Call(args, Reverse!DefVals);
    }
}

void main()
{
    test();
}
