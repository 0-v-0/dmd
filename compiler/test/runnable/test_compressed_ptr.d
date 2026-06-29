/*
REQUIRED_ARGS: -compressed-pointers -m64
RUN_OUTPUT:
---
Success
---
*/

module test_compressed_ptr;

import core.stdc.stdio;
import core.memory;

void testSimple()
{
    int* p = cast(int*)GC.malloc(int.sizeof);
    *p = 42;
    assert(*p == 42);

    *p = 100;
    assert(*p == 100);
}

void testMultiple()
{
    int* p = cast(int*)GC.malloc(int.sizeof);
    int* q = cast(int*)GC.malloc(int.sizeof);
    *p = 10;
    *q = 20;
    assert(*p == 10);
    assert(*q == 20);
}

void testArray()
{
    size_t n = 4;
    int* p = cast(int*)GC.calloc(n * int.sizeof);
    p[0] = 1;
    p[1] = 2;
    p[2] = 3;
    p[3] = 4;
    assert(p[0] == 1);
    assert(p[1] == 2);
    assert(p[2] == 3);
    assert(p[3] == 4);
}

void testPtrArith()
{
    int* p = cast(int*)GC.calloc(4 * int.sizeof);
    p[0] = 1;
    p[1] = 2;
    p[2] = 3;
    p[3] = 4;

    int* q = p + 2;
    assert(*q == 3);

    int* r = q - 1;
    assert(*r == 2);
}

void main()
{
    testSimple();
    testMultiple();
    testArray();
    testPtrArith();

    printf("Success\n");
}
