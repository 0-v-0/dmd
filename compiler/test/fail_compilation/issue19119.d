struct S
{
    int x;
    ~this() { x = 1; }
}

void delegate() makeDelegate()
{
    auto s = S(2);
    return { assert(s.x == 2); };
}

void main()
{
    auto dg = makeDelegate();
    dg();
}
