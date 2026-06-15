struct Foo(T) {}
struct Foo(T : Bar!R, U = int, R) {}
struct Bar(R) {}

Foo!(Bar!float) withDefaultArg;

struct Baz(T) {}
struct Baz(T : Qux!R, R) {}
struct Qux(R) {}

Baz!(Qux!float) withoutDefaultArg;
