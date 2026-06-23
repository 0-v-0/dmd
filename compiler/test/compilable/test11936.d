void main()
{
    int delegate(int delegate(int)) dg1;
    int delegate(int delegate(ref int)) dg2;

    foreach(a; dg1) { }
    static assert(!__traits(compiles, { foreach(ref a; dg1) { } }));
    foreach(ref a; dg2) { }
}
