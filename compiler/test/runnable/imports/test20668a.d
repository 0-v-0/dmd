module imports.test20668a;

import std.signals;

class Session
{
}

enum ActionType
{
    detachTerminal,
    detachSession,
}

class CumulativeResult(T)
{
}

struct GenericEvent(T...)
{
    mixin Signal!T;
}
