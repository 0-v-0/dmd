module test18532;

// https://issues.dlang.org/show_bug.cgi?id=9686
// Issue 18532: Wrong ambiguity overloading error for functions
// with signed/unsigned integral arguments

void f(ulong) { }
void f(long) { }

void main()
{
    short s;
    int i;
    f(s);  // should match f(long), not ambiguous
    f(i);  // should match f(long), not ambiguous
}
