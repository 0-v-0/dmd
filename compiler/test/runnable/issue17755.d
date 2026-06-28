void emplace(S* chunk) { *chunk = S.init; }

struct RefCounted()
{
    struct RefCountedStore
    {
        struct Impl { S _payload; }

        Impl* _store;

        void initialize()
        {
            _store = new Impl;
            emplace(&_store._payload);
        }
    }

    RefCountedStore _refCounted;

    void opAssign(typeof(this) rhs) {}
    void opAssign(S rhs) {}

    ref S refCountedPayload()
    {
        if (_refCounted._store is null) _refCounted.initialize();
        return _refCounted._store._payload;
    }

    alias refCountedPayload this;
}

struct S
{
    int x;
    RefCounted!() s;
}

void main()
{
    S s;

    s.x = 1;
    s.s.x = 2;
    s.s.s.x = 3;

    assert(s.x == 1);
    assert(s.s.x == 2);
    assert(s.s.s.x == 3);
}
