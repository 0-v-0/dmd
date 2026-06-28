// https://issues.dlang.org/show_bug.cgi?id=18981

class A
{
    final void f(this This)()
    {
        static assert(This.stringof == "B");
    }
}

class B : A
{
    void x()
    {
        f();
    }
}

void main()
{
    auto b = new B;
    b.x();
}
