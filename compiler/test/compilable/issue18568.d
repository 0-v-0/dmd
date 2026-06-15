void main()
{
    const(char)* pc = true ? "main" : null;
    const(char)* pc2 = true ? null : "main";
    const(wchar)* pw = true ? "main"w : null;
    const(dchar)* pd = true ? null : "main"d;

    string s = "main";
    static assert(is(typeof(true ? s : null) == string));
    static assert(is(typeof(true ? "main" : null) == const(char)*));
    static assert(is(typeof(true ? null : "main") == const(char)*));
    static assert(is(typeof(true ? "main"w : null) == const(wchar)*));
    static assert(is(typeof(true ? null : "main"d) == const(dchar)*));

    assert(pc !is null);
    assert(pc2 !is null);
    assert(pw !is null);
    assert(pd !is null);
}
