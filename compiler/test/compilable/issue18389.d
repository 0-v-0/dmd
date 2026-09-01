// https://github.com/dlang/dmd/issues/18389
// Test that .stringof produces consistent, round-trippable decimal
// representations with minimum digits and correct type suffixes.

// Float literals - lowercase f suffix, no .0 for integer values
static assert(100001f.stringof     == "100001f");
static assert(1000001f.stringof    == "1000001f");
static assert([100001f].stringof   == "[100001f]");
static assert([1000001f].stringof  == "[1000001f]");

// Double literals - keep .0 to distinguish from integers
static assert(100001.0.stringof    == "100001.0");
static assert(1000001.0.stringof   == "1000001.0");
static assert([100001.0].stringof  == "[100001.0]");
static assert([1000001.0].stringof == "[1000001.0]");

// Additional consistency checks
static assert(1.0f.stringof   == "1f");
static assert(1.0.stringof    == "1.0");
static assert(0f.stringof     == "0f");
static assert(0.0.stringof   == "0.0");
static assert(1.5f.stringof  == "1.5f");
static assert(1.5.stringof   == "1.5");
static assert(3.14159f.stringof == "3.14159f");
static assert(3.14159.stringof  == "3.14159");

