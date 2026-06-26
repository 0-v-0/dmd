import dshell;

int main()
{
    Vars.set(`SRC`, `$EXTRA_FILES/issue20541`);
    Vars.set(`DRUNTIME_SRC`, `$TEST_DIR/../../../../druntime/src`);
    Vars.set(`DLL`, `$OUTPUT_BASE/issue20541$SOEXT`);
    Vars.set(`EXE_OK`, `$OUTPUT_BASE/issue20541_ok$EXE`);
    Vars.set(`EXE_FAIL`, `$OUTPUT_BASE/issue20541_fail$EXE`);

    version (Windows)
    {
        enum dllExtra = `$SRC/dllmain.d`;
        enum clientExtra = `$OUTPUT_BASE/issue20541$LIBEXT`;
    }
    else
    {
        enum dllExtra = `-fPIC`;
        enum clientExtra = `-fPIC -L-L$OUTPUT_BASE -L$DLL`;
    }

    run(`$DMD -m$MODEL -I$DRUNTIME_SRC -shared -H -Hd=$OUTPUT_BASE -od=$OUTPUT_BASE -of=$DLL $SRC/mydll.d ` ~ dllExtra);
    run(`$DMD -m$MODEL -I$DRUNTIME_SRC -I=$OUTPUT_BASE -od=$OUTPUT_BASE -of=$EXE_OK $SRC/test_ok.d ` ~ clientExtra);

    auto failExit = tryRun(`$DMD -m$MODEL -I$DRUNTIME_SRC -I=$OUTPUT_BASE -od=$OUTPUT_BASE -of=$EXE_FAIL $SRC/test_hidden.d ` ~ clientExtra);
    assert(failExit != 0);

    return 0;
}
