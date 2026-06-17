module issue17936_b;

version (X86)
{
    import issue17936_dep;

    extern(C) size_t addrB()
    {
        return cast(size_t)&Version.masterBranch;
    }
}
