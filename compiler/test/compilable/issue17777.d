// https://issues.dlang.org/show_bug.cgi?id=17777
// Template shape misdetected in is() expression with type qualifiers

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

// Mutable Test!char should match the third case (Test!X), returning char
static assert(is(PropagateQualifier!(Test!char) == char));

// Immutable Test!char should match the first case (immutable(Test!X))
static assert(is(PropagateQualifier!(immutable(Test!char)) == immutable char));

// const Test!char should match the second case (const Test!X)
static assert(is(PropagateQualifier!(const Test!char)) && is(PropagateQualifier!(const Test!char) == const char));
