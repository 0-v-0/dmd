/*
TEST_OUTPUT:
---
fail_compilation/test20012.d(8): Error: array cast from `string` to `dstring` is not supported at compile time
---
*/

@(cast(dstring) "huh"c) int x;
