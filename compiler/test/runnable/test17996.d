// https://issues.dlang.org/show_bug.cgi?id=17996

extern(C++)
mixin template MTC()
{
    int foo(int i)
    {
        return i;
    }
}

mixin MTC!();

static assert(__traits(getLinkage, foo) == "C++");

void main()
{
    assert(foo(42) == 42);
}
