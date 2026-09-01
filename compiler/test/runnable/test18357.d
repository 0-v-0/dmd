/*
TEST_OUTPUT:
---
---
*/

/* Test that const static arrays are optimized like enum arrays.
   See https://issues.dlang.org/show_bug.cgi?id=18357
*/

enum int[1] array1 = [10];
int foo(int[1] v) {
    return array1[0] * v[0];
}
const int[1] array2 = [10];
int bar(int[1] v) {
    return array2[0] * v[0];
}

void main()
{
    int[1] v = [3];
    assert(foo(v) == 30);
    assert(bar(v) == 30);

    // Test with larger arrays
    const int[3] arr = [1, 2, 3];
    assert(arr[0] == 1);
    assert(arr[1] == 2);
    assert(arr[2] == 3);

    // Test immutable arrays
    immutable int[2] iarr = [5, 7];
    assert(iarr[0] == 5);
    assert(iarr[1] == 7);

    // Test const with different types
    const long[2] larr = [100L, 200L];
    assert(larr[0] == 100);
    assert(larr[1] == 200);

    // Test that enum and const produce same results
    enum int[4] earr = [10, 20, 30, 40];
    const int[4] carr = [10, 20, 30, 40];
    foreach (i; 0..4)
        assert(earr[i] == carr[i]);
}
