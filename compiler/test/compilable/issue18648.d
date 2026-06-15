// REQUIRED_ARGS: -c -release -O -inline

pragma(inline, false)
void foo(int line = __LINE__)()
{
    int x = 1;
    x += 2;
}

void main()
{
    foo();
    foo();
}
