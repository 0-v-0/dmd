struct W(T)
{
    T t;
}

auto wrap0(T)(auto ref inout(T) t)
{
    return inout(W!T)(t);
}

auto wrap1(T)(auto ref inout(T) t)
{
    return t;
}

void main()
{
    immutable int i0;
    string s0 = "baz";

    static assert(is(typeof(wrap0("foo")) == W!string));
    static assert(is(typeof(wrap1("bar")) == string));
    static assert(is(typeof(wrap1(i0)) == immutable(int)));
    static assert(is(typeof(wrap0(s0)) == W!string));
}
