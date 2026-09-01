module issue17936_a;

version (X86)
{
    import issue17936_dep;

    extern(C) size_t addrA()
    {
        return cast(size_t)&Version.masterBranch;
    }
}
