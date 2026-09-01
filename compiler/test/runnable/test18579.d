module test18579;
// https://issues.dlang.org/show_bug.cgi?id=10052
// Issue 18579: Tuple not assignable in shared static module constructor
// Regression test - compiler allows opAssign on shared static struct
struct Tup { int a, b; void opAssign(Tup rhs) { a = rhs.a; b = rhs.b; } }
shared static Tup ints;
shared static this() { ints = Tup(4, 6); }
void main() {}
