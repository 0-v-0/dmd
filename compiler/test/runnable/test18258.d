// https://github.com/dlang/dmd/issues/18258

import core.atomic : atomicLoad;

shared class Foo
{
    int y;

    shared class Bar
    {
        synchronized int x()
        {
            return y;
        }
    }
}

void main()
{
    shared(Foo) foo = new Foo();
    auto bar = foo.new Bar;

    assert(foo.__monitor !is null);
    assert(bar.__monitor == foo.__monitor);

    synchronized (bar)
    {
    }

    synchronized (foo)
    {
    }

    auto fooCopy = atomicLoad(foo);
    auto barCopy = atomicLoad(bar);
    assert(barCopy.__monitor == fooCopy.__monitor);
    assert(barCopy.x() == 0);
}
