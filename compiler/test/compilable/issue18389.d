static assert(100001f.stringof == "100001f");
static assert(1000001f.stringof == "1000001f");
static assert([100001f].stringof == "[100001f]");
static assert([1000001f].stringof == "[1000001f]");

static assert(100001.0.stringof == "100001.0");
static assert(1000001.0.stringof == "1000001.0");
static assert([100001.0].stringof == "[100001.0]");
static assert([1000001.0].stringof == "[1000001.0]");

void main()
{
}
