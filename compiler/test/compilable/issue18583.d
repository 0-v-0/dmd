void test(int[3] arg0..., int[3] arg1...)
{
    static assert(is(typeof(arg0) == int[3]));
    static assert(is(typeof(arg1) == int[3]));
    assert(arg0 == [1, 2, 3]);
    assert(arg1 == [4, 5, 6]);
}

void main()
{
    test(1, 2, 3, 4, 5, 6);
}
