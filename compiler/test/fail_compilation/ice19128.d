/*
TEST_OUTPUT:
---
fail_compilation/ice19128.d(16): Error: cannot get frame pointer to `ice19128.main.hun!(void delegate() pure nothrow @nogc @safe).hun`
        a(&gun);
         ^
---
*/

module ice19128;

void fun(alias a)()
{
    auto dg = () {
        void gun() { }
        a(&gun);
    };
}

void main()
{
    void hun(R)(R) { }
    fun!hun();
}
