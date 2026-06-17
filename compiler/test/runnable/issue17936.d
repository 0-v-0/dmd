// REQUIRED_ARGS: -cov
// EXTRA_SOURCES: extra-files/issue17936_dep.d extra-files/issue17936_a.d extra-files/issue17936_b.d

version (X86)
{
    import issue17936_a;
    import issue17936_b;

    void main()
    {
        assert(addrA() == addrB());
    }
}
else
{
    void main() {}
}
