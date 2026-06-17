// https://issues.dlang.org/show_bug.cgi?id=16581

struct Test(T) {}

template PropagateQualifier(Q)
{
    static if (is(Q == immutable(Test!X), X))
        alias PropagateQualifier = immutable X;
    else static if (is(Q == const Test!X, X))
        alias PropagateQualifier = const X;
    else static if (is(Q == Test!X, X))
        alias PropagateQualifier = X;
    else static assert(0);
}

static assert(is(PropagateQualifier!(Test!char) == char));
static assert(is(PropagateQualifier!(const(Test!char)) == const char));
static assert(is(PropagateQualifier!(Test!(immutable char)) == immutable char));
