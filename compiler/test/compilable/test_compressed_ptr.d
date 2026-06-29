/* REQUIRED_ARGS: -compressed-pointers -m64
 */

module test_compressed_ptr;

// Basic pointer sizes
static assert(int*.sizeof == 4);
static assert(long*.sizeof == 4);
static assert(double*.sizeof == 4);
static assert(void*.sizeof == 4);
static assert(ubyte*.sizeof == 4);

// Struct with compressed pointer fields
struct S
{
    int* p;
    double* q;
}
static assert(S.p.offsetof == 0);
static assert(S.q.offsetof == 4);
static assert(S.sizeof == 8);

// Pointer arithmetic
void testArith()
{
    int x;
    int* p = &x;
    p = p + 1;
    p = p - 1;
    ++p;
    --p;
    int* q = p + 10;
    ptrdiff_t diff = q - p;
}

// Pointer dereference
void testDeref()
{
    int x = 42;
    int* p = &x;
    int y = *p;
    *p = 100;
}

// Index via pointer
void testIndex()
{
    int[4] arr;
    int* p = arr.ptr;
    p[0] = 1;
    p[1] = 2;
}

// Nested pointers
void testNested()
{
    int x = 42;
    int* p = &x;
    int** pp = &p;
    int y = **pp;
}

// Comparison
void testCompare()
{
    int x, y;
    int* p = &x;
    int* q = &y;
    bool b;
    b = (p == q);
    b = (p != q);
    b = (p < q);
    b = (p <= q);
    b = (p > q);
    b = (p >= q);
}

// Null
void testNull()
{
    int* p = null;
    bool b = (p is null);
    b = (p !is &p);
}

// Void pointer
void testVoidPtr()
{
    int x = 42;
    void* p = &x;
}

// Const/immutable
void testConst()
{
    int x = 42;
    const(int)* p = &x;
    immutable(int)* q;
}

// Pointer to function
void testFuncPtr()
{
    int function(int) fp = &testFuncPtr;
}

extern(C) int main()
{
    testArith();
    testDeref();
    testIndex();
    testNested();
    testCompare();
    testNull();
    testVoidPtr();
    testConst();
    testFuncPtr();
    return 0;
}
