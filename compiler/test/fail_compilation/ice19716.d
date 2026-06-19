/*
TEST_OUTPUT:
---
fail_compilation/ice19716.d(20): Error: static foreach over non-terminating range
fail_compilation/ice19716.d(20):        called from here: `(*function () @system => __res3)()`
---
*/

struct SimpleRange
{
    this(int front) { this.front = front; }

    bool empty = false;
    int front;
    void popFront() { }
}

void main()
{
    static foreach (x; SimpleRange(1)) { }
}
