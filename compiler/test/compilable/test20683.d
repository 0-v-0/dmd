// https://github.com/dlang/dmd/issues/20683

bool foo(alias F)(bool b) => F(b);

unittest
{
    struct Bar
    {
        static if (foo!(a => a)(true))
        {
            enum foobar = true;
        }
    }

    static assert(Bar.foobar);
}
