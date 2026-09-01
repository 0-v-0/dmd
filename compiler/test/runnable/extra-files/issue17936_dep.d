module issue17936_dep;

version (X86)
{
    struct Version
    {
        string value;

        static immutable Version masterBranch = Version("dub.json");
    }
}
