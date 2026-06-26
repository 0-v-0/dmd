module test19959;

__gshared struct Foo
{
    int bar;
}

__gshared Foo foo;
void* bar_ptr = &foo.bar;

void main()
{
}
