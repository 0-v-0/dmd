// https://issues.dlang.org/show_bug.cgi?id=13189
// Issue 18855 - alias this is not transitive

struct S
{
    int x;
    int y;
}

struct T
{
    S s;
    alias s this;
}

static assert(is(typeof(T.init.x)));
static assert(is(typeof(T.init.y)));

struct U
{
    T t;
    alias x = t.x;
}
