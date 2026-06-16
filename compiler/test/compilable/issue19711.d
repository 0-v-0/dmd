void main()
{
    void foo(alias T: int)(T t)
    {
        static assert(is(T == int));
    }

    foo(1);
}
