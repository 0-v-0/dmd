/*
TEST_OUTPUT:
---
fail_compilation/issue19078.d(18): Error: return value `d` of type `dchar` does not match return type `char`, and cannot be implicitly converted
fail_compilation/issue19078.d(24): Error: template instance `issue19078.MapResult!()` error instantiating
fail_compilation/issue19078.d(10):        instantiated from here: `map!()`
---
*/

enum e = is(typeof(map()));

struct MapResult()
{
    this(char[] a) {}
    char front()
    {
        dchar d;
        return d;
    }
}

void map()()
{
    auto mr = MapResult!()([]);
}

void main()
{
    map();
}
