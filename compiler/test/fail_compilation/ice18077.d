/*
REQUIRED_ARGS: -verrors=spec -o-
TEST_OUTPUT:
---
(spec:1) fail_compilation/ice18077.d(18): Error: union `ice18077.SumType!(Scope, Return).SumType.Storage` no size because of forward reference
---
*/

enum isHashable(T) = __traits(compiles, T.init.tupleof[0][0].sizeof);

struct SumType(Types...)
{
    union Storage
    {
        Types values;
    }

    Storage storage;

    static if (isHashable!(Types[0])) {}
}

string[] toLines(Expression val)
{
    return [];
}

alias Expression = SumType!(Scope, Return);

struct Return
{
    Expression* _expr = new Expression;
}

struct Scope
{
    Expression[] statements;

    string[] toLines()
    {
        return Expression.init.toLines;
    }
}
