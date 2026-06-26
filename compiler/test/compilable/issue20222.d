// https://issues.dlang.org/show_bug.cgi?id=23664

module issue20222;

void takes(int delegate() dg) {}

void test20222()
{
    int x = 1;
    auto dg = delegate int() { return x; };
    static assert(is(typeof(dg) == int delegate() const pure nothrow @nogc @safe));
    takes(dg);

    immutable int y = 2;
    auto ig = delegate int() { return y; };
    static assert(is(typeof(ig) == int delegate() immutable pure nothrow @nogc @safe));
    takes(ig);
}
