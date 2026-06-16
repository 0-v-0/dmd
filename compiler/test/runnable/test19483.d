auto ref run(F, Args...)(F dg, auto ref Args args)
{
    return dg(args);
}

auto makeClosure(alias func, Args...)(auto ref Args args)
{
    auto fptr = args[0].funcptr;
    return {
        assert(args[0].funcptr is fptr);
        return func(args);
    };
}

auto test(F, Args...)(F dg, auto ref Args args)
{
    return makeClosure!run(dg, args);
}

void main()
{
    auto t = test(delegate () => 10);
    assert(t() == 10);
}
