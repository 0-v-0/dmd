void main()
{
    int[2][] foo = [[1, 1]];
    int[2][] bar = foo ~ [[1, 1]];
    int[2][] baz = [[1, 1]] ~ foo;

    assert(bar.length == 2);
    assert(baz.length == 2);
}
