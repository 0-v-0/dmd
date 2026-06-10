version (Windows)
{
    import core.sys.windows.objbase;
    import core.sys.windows.basetyps : GUID;

    void testObjbaseBindings() @nogc nothrow
    {
        GUID guid;
        CoTaskMemFree(null);
        auto isEqual = IsEqualGUID(&guid, &guid);
        if (isEqual)
        {
        }
    }
}
