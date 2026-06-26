// REQUIRED_ARGS: -preview=dip1000
// https://issues.dlang.org/show_bug.cgi?id=18130

struct S
{
    int* a, b;
}

int* example(int* p) @safe
{
    int n;
    scope int* sp = &n;
    S s;
    s.a = sp;
    s.b = p;
    return s.b;
}
