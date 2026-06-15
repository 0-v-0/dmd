void foo(T)(T x, T.Inner y)
{
    static assert(is(T == Bar));
    static assert(is(typeof(y) == int));
}

struct Bar
{
    alias int Inner;
}

void main()
{
    foo(Bar(), 0);
}
