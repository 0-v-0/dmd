class A
{
    void foo(out A a)
    {
        a = new A;
    }
}

class B : A
{
    override void foo(out B b)
    {
        b = new B;
    }
}

void main()
{
    A base = new B;
    A a;
    base.foo(a);
    static assert(is(typeof(cast(B) a)));
}
