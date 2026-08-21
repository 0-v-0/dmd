// https://issues.dlang.org/show_bug.cgi?id=20432
// extern(C++, class|struct) should not apply to inner types

extern(C++, class) struct Container19685
{
    struct Inner
    {
        int val;
    }
}

extern(C++) void foo19685(const ref Container19685.Inner);

// Inner is a struct, not a class, so it should be mangled with 'U' not 'V'
// On Windows MSVC x64: 'U' = struct, 'V' = class
// (the class/struct distinction only exists with MSVC C++ mangling)
version (CppMangleMSVC)
    static assert(foo19685.mangleof == "?foo19685@@YAXAEBUInner@Container19685@@@Z");
