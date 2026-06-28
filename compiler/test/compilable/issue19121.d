template FieldTypeTuple(T)
{
    alias FieldTypeTuple = typeof(T.tupleof);
}

struct RefCounted(T)
{
    alias Fields = FieldTypeTuple!T;
}

struct S
{
    int x;
    RefCounted!S s;
}

void main()
{
}
