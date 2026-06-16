/*
TEST_OUTPUT:
---
fail_compilation/test18902.d(8): Error: mismatched array lengths, 2 and 1
fail_compilation/test18902.d(9): Error: cannot implicitly convert expression `[1.5, 2.5]` of type `double[]` to `int[2]`
---
*/

void main()
{
    uint[1][2] arr1 = [[0, 0]];
    int[2] arr2 = [1.5, 2.5];
}
