struct S
{
    string s = "{}";
    alias s this;
}

struct Expr
{
    string s = "1 + 2";
    alias s this;
}

void main()
{
    static assert(S() == "{}");
    mixin(S());

    static assert(mixin(Expr()) == 3);
}
