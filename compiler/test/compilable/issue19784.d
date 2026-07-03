// https://issues.dlang.org/show_bug.cgi?id=19784

import core.internal.hash;

struct Node
{
    NodePtr[] choices;

    void visit(Handler)(Handler h)
    {
        foreach (i, f; this.tupleof)
            if (h.handle(p => &p.tupleof[i]))
                return;
    }

    mixin AutoVisitor;
}

struct NodePtr
{
    mixin AutoVisitor;

    void visit(Handler)(Handler h)
    {
        h.handle(p => p);
    }
}

template AutoVisitor()
{
    size_t toHash()
    {
        alias T = typeof(this);
        struct Handler
        {
            T* self;
            bool handle(F)(F* delegate(T*) dg)
            {
                auto a = dg(self);
                hashOf(*a);
                return true;
            }
        }
        visit!(Handler*)(null);
        return 0;
    }
}

void main() {}
