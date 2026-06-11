module imports.test20668b;

import imports.test20668a;

struct Holder
{
    GenericEvent!int event;
}

struct ComplexHolder
{
    GenericEvent!Session sessionEvent;
    GenericEvent!(ActionType, CumulativeResult!bool) actionEvent;
    GenericEvent!(string, string, string, string) processEvent;
}

bool same(ref const GenericEvent!int lhs, ref const GenericEvent!int rhs)
{
    return lhs == rhs;
}

bool sameHolder(ref const Holder lhs, ref const Holder rhs)
{
    return lhs == rhs;
}

bool sameComplexHolder(ref const ComplexHolder lhs, ref const ComplexHolder rhs)
{
    return lhs == rhs;
}
