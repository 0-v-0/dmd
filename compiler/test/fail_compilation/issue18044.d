/*
TEST_OUTPUT:
---
fail_compilation/issue18044.d(19): Error: cannot modify captured variable `pos` in `const` function
            ++pos;
              ^
fail_compilation/issue18044.d(19): Error: cannot modify captured variable `pos` in `const` function
            ++pos;
              ^
---
*/
void main()
{
    int pos;
    struct R
    {
        void popFront() const
        {
            ++pos;
        }
    }
    auto r = R();
    r.popFront();
}
