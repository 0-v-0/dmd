/*
TEST_OUTPUT:
---
---
*/

// https://issues.dlang.org/show_bug.cgi?id=18637
// opDispatch should not be tried as property when it requires runtime arguments
// and alias this can resolve the member

struct Test1
{
    int i;
}

struct Test2
{
    Test1 test1;
    alias test1 this;
    int opDispatch(string id)(string dummy)
    {
        return 42;
    }
}

void main()
{
    Test2 test2;
    auto x = test2.i;
    assert(x == 0);
    auto y = test2.i("hello");
    assert(y == 42);
}
