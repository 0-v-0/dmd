// Test for issue 18038: duping a recursive ctfe param can crash dmd
// https://issues.dlang.org/show_bug.cgi?id=21984

struct ContainerMeta {
    string s;
    ContainerMeta[] children;
}

template Container(Thing) {
    class Container : Thing {
        static ContainerMeta opCall(ContainerMeta[] children...) {
            return ContainerMeta("foo", children.dup);
        }
    }
}

class Thing {}

// Test 1: Basic recursive struct CTFE with opCall
ContainerMeta test1() {
    return Container!Thing.opCall(ContainerMeta("bar"));
}

// Test 2: Nested recursive struct in CTFE
ContainerMeta test2() {
    return ContainerMeta("a", [ContainerMeta("b", [ContainerMeta("c")])]);
}

// Test 3: Struct parameter copy (non-const, by value)
ContainerMeta modify(ContainerMeta c) {
    c.s = "modified";
    return c;
}

// Test 4: Array concat of recursive structs
ContainerMeta[] test4() {
    ContainerMeta[] a = [ContainerMeta("a")];
    ContainerMeta[] b = [ContainerMeta("b")];
    return a ~ b;
}

// Test 5: Default-initialized recursive struct
ContainerMeta test5() {
    ContainerMeta c;
    c.s = "default";
    return c;
}

// Test 6: opCall with no arguments (empty variadic)
ContainerMeta test6() {
    return Container!Thing.opCall();
}

void main() {
    // Trigger CTFE and scrubCacheValue via manifest constants
    enum x1 = test1();
    assert(x1.s == "foo");
    assert(x1.children[0].s == "bar");

    enum x2 = test2();
    assert(x2.s == "a");
    assert(x2.children[0].s == "b");
    assert(x2.children[0].children[0].s == "c");

    enum x3 = modify(ContainerMeta("orig", [ContainerMeta("child")]));
    assert(x3.s == "modified");

    enum x4 = test4();
    assert(x4[0].s == "a");
    assert(x4[1].s == "b");

    enum x5 = test5();
    assert(x5.s == "default");

    enum x6 = test6();
    assert(x6.s == "foo");

    pragma(msg, "issue18038 OK");
}
