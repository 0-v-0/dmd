module test18574;
struct S { }
class Test2 { this(S) pure {} }
void main() { auto t2 = new shared Test2(S()); auto t3 = new immutable Test2(S()); }
