/*
TEST_OUTPUT:
---
 fail_compilation/fail18856.d(14): Error: undefined identifier `std` in module `std.stdio`
 fail_compilation/fail18856.d(15): Error: undefined identifier `std` in module `std.array`
---
*/

import std.stdio;
import std.array;

void main()
{
    std.stdio.std.stdio.writeln("123");
    auto fmt = std.array.std.array.appender!(string)();
}
