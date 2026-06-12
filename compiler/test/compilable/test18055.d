version (Windows)
{
    struct S(alias F)
    {
        extern (C++) static impl()
        {
        }
    }

    class C
    {
        void f();
        void f(int);
    }

    S!(__traits(getOverloads, C, "f")[0]) x;
}
