void f(ulong) {}
void f(long) {}

void main()
{
    ushort us = 0;
    short s = 0;
    uint ui = 0;
    int i = 0;

    static assert(!__traits(compiles, f(us)));
    static assert(!__traits(compiles, f(ui)));
    static assert(__traits(compiles, f(s)));
    static assert(__traits(compiles, f(i)));

    f(s);
    f(i);
}
