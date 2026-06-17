void main() @safe
{
    union Foo
    {
        int a;
        int* b;
    }

    Foo foo;
    int* p;
    foo.b = p;

    static assert(__traits(compiles, {
        @safe void test()
        {
            Foo bar;
            int* q;
            bar.b = q;
        }
    }));

    static assert(!__traits(compiles, {
        @safe void test()
        {
            Foo bar;
            int* c = bar.b;
        }
    }));
}
