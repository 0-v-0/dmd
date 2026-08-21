// https://github.com/dlang/dmd/issues/18555
// dchar concat "string literal" is not allowed
void main()
{
    dchar c = 'A';
    dstring s0 = "bcd";  // OK
    auto s1 = c ~ s0;    // OK
    auto s2 = c ~ "bcd"; // was Error, should compile
    static assert(is(typeof(s2) == dstring));

    // wchar ~ string literal should also work
    wchar w = 'B';
    auto w2 = w ~ "cde";
    static assert(is(typeof(w2) == wstring));

    // char ~ string literal should still be string
    char ch = 'A';
    auto c2 = ch ~ "bcd";
    static assert(is(typeof(c2) == string));
}
