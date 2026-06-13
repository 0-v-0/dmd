import core.exception : AssertError;
import std.exception : assertThrown;

struct Result
{
    bool ok;
    string msg;
}

void require(Result result)
in (result.tupleof)
do
{
}

void main()
{
    assert(Result(true, "unused").tupleof);
    require(Result(true, "unused"));

    assertThrown!AssertError({
        assert(Result(false, "hello world").tupleof);
    }(), "hello world");

    assertThrown!AssertError({
        require(Result(false, "contract message"));
    }(), "contract message");
}
