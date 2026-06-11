void main()
{
    void foo() {}
    void foo(int) {}

    static void bar() {}
    static void bar(int) {}

    foo();
    foo(1);
    bar();
    bar(1);
}
