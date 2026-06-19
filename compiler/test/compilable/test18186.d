/*
REQUIRED_ARGS: -betterC -I=druntime/src
*/

// https://github.com/dlang/dmd/issues/18186

void main()
{
    noreturn[1] x = noreturn[1].init;
}
