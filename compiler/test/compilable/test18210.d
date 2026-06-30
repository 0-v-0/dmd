// https://issues.dlang.org/show_bug.cgi?id=18210

alias seq(T...) = T;

template foo(T...)
{
    alias bar = seq!();
    static foreach (i, A; T)
    {
        alias bar_(alias B : A) = bar;
        bar = seq!(bar_!A, A);
    }
    alias foo = bar;
}

alias foobar = foo!(int, bool, float);
static assert(foobar.stringof == "(int, bool, float)");

void main()
{
}
