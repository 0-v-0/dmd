extern(C++):

extern(C++, class) struct Container
{
    struct Inner
    {
        int val;
    }
}

void foo(const ref Container.Inner);

extern(C++, class) struct Outer
{
    extern(C++, class) struct Inner
    {
        int val;
    }
}

void bar(const ref Outer.Inner);

version (CppMangle_MSVC)
{
    static assert(foo.mangleof == "?foo@@YAXAEBUInner@Container@@@Z");
    static assert(bar.mangleof == "?bar@@YAXAEBVInner@Outer@@@Z");
}
