// https://issues.dlang.org/show_bug.cgi?id=18924
// __gshared/static anonymous union members should overlap

struct Foo
{
    union
    {
        int a;
        int b;
    }
}

struct Bar
{
    __gshared union
    {
        int a;
        int b;
    }
}

void main()
{
    Foo x;
    Bar y;
    assert(&x.a is &x.b);
    assert(&y.a is &y.b);
}
