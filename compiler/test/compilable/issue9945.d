// https://issues.dlang.org/show_bug.cgi?id=9945

class Base {}
class Derived : Base {}

TypeInfo foo()
{
    return typeid(int);
}

TypeInfo bar()
{
    Derived d = new Derived;
    Base b = d;
    return typeid(b);
}

static assert(is(__traits(typeFromId, typeid(int)) == int));
static assert(is(__traits(typeFromId, foo()) == int));
static assert(is(__traits(typeFromId, bar()) == Derived));

void main() {}
