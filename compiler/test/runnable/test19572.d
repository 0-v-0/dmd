struct S3
{
    auto opDispatch(string name, Args...)(Args args)
    {
        static assert(Args.length == 1);
        static assert(is(Args[0] == int));
        assert(args[0] == 1);
    }
}

void main()
{
    with (S3.init)
    {
        a(1);
    }
}
