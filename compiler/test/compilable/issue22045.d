// https://issues.dlang.org/show_bug.cgi?id=22045
// Writing to a pointer field in a union should be @safe

union Foo
{
    int a;
    int* b;
}

void main() @safe
{
    Foo foo;
    foo.b = new int;

    // Writing through the union is @safe
    foo.b = new int;
}

// Reading a pointer from a union should be @system
// (commented out because it should fail to compile)
/+
void testRead() @safe
{
    Foo foo;
    int* c = foo.b; // should be @system
}
+/
