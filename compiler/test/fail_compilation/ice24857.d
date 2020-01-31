/*
TEST_OUTPUT:
---
fail_compilation/ice24857.d(8): Error: initializer expression expected following colon, not `]`
---
*/

static initial = [{ }: ];
