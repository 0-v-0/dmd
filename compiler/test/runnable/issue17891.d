// https://github.com/dlang/dmd/issues/17891
// REQUIRED_ARGS: -defaultlib=

import core.exception : AssertError;

class A
{
    int i = 3;
    invariant { assert(i >= 2); }
}

class B : A
{
    void setB(int v) { i = v; }
    invariant { assert(i <= 10); }
}

void main()
{
    try
    {
        auto b = new B;
        b.setB(1);
        assert(false, "Failed: base class invariant in derived class was not checked");
    }
    catch (AssertError)
    {
        // Expected behavior - base class invariant was checked
    }
}
