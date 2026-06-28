bool frop(int f)
{
    return true;
}

class Bar
{
    int zoo;

    class Foo
    {
        bool foo()
        {
            return (zoo).frop();
        }
    }
}

void main()
{
}
