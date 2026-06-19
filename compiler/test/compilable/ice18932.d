// https://github.com/dlang/dmd/issues/18932

import std.typecons : BlackHole;

extern(C++) interface Inter
{
    void func();
}

BlackHole!Inter var;
