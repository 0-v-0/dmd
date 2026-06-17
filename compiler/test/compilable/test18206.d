struct T
{
    int i = 3;
    int[100] x;
}

pragma(inline, false)
T make()
{
    T t = T.init;
    return t;
}

void main()
{
    auto t = make();
}
