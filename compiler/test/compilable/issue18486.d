module issue18486;

template Int(T)
{
    alias int Int;
}

void f1(T)(T t, Int!T[] arr) { }
void f2(T, U = Int!T)(T t, U[] arr) { }
void f3(T, U : Int!T)(T t, U[] arr) { }
void f4(T, U : V, V = Int!T)(T t, U[] arr) { }
void f5(T, U = Int!T)(T t, U[] arr) if (is(U == Int!T)) { }

void main()
{
    int i;
    int[] arr;
    f1!int(i, arr);
    f1(i, arr);
    f1(i, []);
    f1(i, null);

    f2!int(i, arr);
    f2(i, arr);
    f2(i, []);
    f2(i, null);

    f3!int(i, arr);
    f3(i, arr);
    f3(i, []);
    f3(i, null);

    f4!int(i, arr);
    f4(i, arr);
    f4(i, []);
    f4(i, null);

    f5!int(i, arr);
    f5(i, arr);
    f5(i, []);
    f5(i, null);
}
