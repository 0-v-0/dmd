// https://issues.dlang.org/show_bug.cgi?id=19683

template AliasSeq(T...)
{
    alias AliasSeq = T;
}

struct S()
{
    void fun() { gun(""); }
    void gun(T)(T)
    {
        alias buggy = bug;
    }
}

alias X = S!();
void main() { X().gun(0); }
alias bug = AliasSeq!(__traits(getMember, X, "fun"));