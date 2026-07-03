// REQUIRED_ARGS: -inline -O -release
// https://issues.dlang.org/show_bug.cgi?id=19699

struct V
{
    bool alive = true;
    void checkAlive() { assert(alive); }
}

struct S
{
    V v;
    @disable this(this);
    ~this() { v.alive = false; }
}

void main()
{
    S().v.checkAlive();
}
