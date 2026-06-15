void main()
{
    dchar c = 'A';
    dstring ds = "bcd";
    string s = "bcd";

    auto s1 = c ~ ds;
    auto s2 = c ~ "bcd";
    auto s3 = "bcd" ~ c;

    static assert(is(typeof(s1) == dstring));
    static assert(is(typeof(s2) == dstring));
    static assert(is(typeof(s3) == dstring));
    static assert(!__traits(compiles, c ~ s));
    static assert(!__traits(compiles, s ~ c));
}
