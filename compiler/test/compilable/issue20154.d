// https://issues.dlang.org/show_bug.cgi?id=23365
// Throwing the bottom value should be allowed
// The bottom type noreturn is convertible to any type, including Throwable.

@safe void test()
{
    throw *null;
}

// Normal throws should still work
void test2() {
    throw new Exception("test");
}
