// https://issues.dlang.org/show_bug.cgi?id=11170

mixin template test()
{
    int next;
}

void foo(alias l)()
{
    l.next = 0;
}

void bar(alias l, alias t)()
{
    l.next = 0;
}

void main()
{
    struct A
    {
        int next;
    }

    A a;

    mixin test l1;
    mixin test l2;

    foo!(a);
    foo!(l1);
    bar!(l1, a);
    bar!(l1, l2);
}
