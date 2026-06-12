/*
https://issues.dlang.org/show_bug.cgi?id=21778

REQUIRED_ARGS: -m64 -release -checkaction=context
*/

extern (C) float getreal_rcx(cfloat z)
{
    return z.re;
}

extern (C) float getimag_rcx(cfloat z)
{
    return z.im;
}

extern (C) int main()
{
    version (Windows)
    {
        cfloat[1] a;
        float[1] b;
        int i;

        a[] = 2 + 4i;
        b[] = 3.0f;

        assert(getreal_rcx(a[i] * b[i]));
        const im = getimag_rcx(a[i] * b[i]);
        assert(im == 12.0f);
    }

    return 0;
}
