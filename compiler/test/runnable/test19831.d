// https://issues.dlang.org/show_bug.cgi?id=19831
// Indexing a tuple in a static array type suffix should work

struct Tuple(T...)
{
    T expand;
    alias expand this;
}

enum s = Tuple!(int[1])([1]);
int[s[0].length] a;

void main()
{
    assert(a.length == 1);
}
