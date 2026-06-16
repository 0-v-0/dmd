mixin template foobar()
{
    this() {}
}

class One
{
    mixin foobar;

    this(int a)
    {
        this();
    }
}

class Two : One
{
}

void main()
{
    auto two = new Two;
    assert(two !is null);
}
