// https://issues.dlang.org/show_bug.cgi?id=18175

module issue18175;

void call(void delegate(int i) cb) {
    cb(42);
}

struct C {
    void callback(int i) const { }
}

void main() {
    C c;
    call(some_int => c.callback(some_int));
}
