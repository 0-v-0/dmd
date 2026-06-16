// https://github.com/dlang/dmd/issues/18234
// Nested type sequences should expand element-wise.

void testConst(Ts...)(const(Ts) args)
{
    static assert(is(typeof(args[0]) == const(int*)));
    static assert(is(typeof(args[1]) == const(int*)));
}

void testPointer(Ts...)(Ts* args)
{
    static assert(is(typeof(args[0]) == int*));
    static assert(is(typeof(args[1]) == int*));
}

void testArray(Ts...)(Ts[] args)
{
    static assert(is(typeof(args[0]) == int[]));
    static assert(is(typeof(args[1]) == int[]));
}

int id(int x)
{
    return x;
}

void testFunction(Ts...)(Ts function(int) args)
{
    static assert(is(typeof(args[0]) == int function(int)));
}

void main()
{
    int i;

    testConst(&i, &i);
    testConst!(int*, int*)(&i, &i);

    testPointer(&i, &i);
    testPointer!(int, int)(&i, &i);

    testArray([i], [i]);
    testArray!(int, int)([i], [i]);

    testFunction(&id);
    testFunction!int(&id);
}
