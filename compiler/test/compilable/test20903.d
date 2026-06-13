void main()
{
    int x;

    ref typeof(x) r0 = x;
    auto ref typeof(x) r1 = 0;
    static assert(__traits(isRef, r0));
    static assert(!__traits(isRef, r1));

    typeof(function { return 0; }()) v0 = x;
    typeof(function { return 0; }()) v1 = 0;
    ref typeof(function { return 0; }()) r2 = x;
    auto ref typeof(function { return 0; }()) r3 = x;
    auto ref typeof(function { return 0; }()) r4 = 0;

    static assert(is(typeof(v0) == int));
    static assert(is(typeof(v1) == int));
    static assert(is(typeof(r2) == int));
    static assert(is(typeof(r3) == int));
    static assert(is(typeof(r4) == int));
    static assert(__traits(isRef, r2));
    static assert(__traits(isRef, r3));
    static assert(!__traits(isRef, r4));

    typeof(function { return x; }) fp = null;
    static assert(!is(typeof(&fp())));
}
