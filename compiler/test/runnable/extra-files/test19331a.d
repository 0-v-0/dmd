module test19331a;

import core.attribute : selector;

extern (Objective-C)
interface NSApplication
{
    NSApplication shared_() @selector("sharedApplication");
}

extern (Objective-C)
interface AppDelegate
{
    AppDelegate alloc() @selector("alloc");
}

void alloc()
{
    AppDelegate a;
    a.alloc();
}

void shared_()
{
    NSApplication a;
    a.shared_();
}
