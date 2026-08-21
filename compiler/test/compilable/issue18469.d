// https://github.com/dlang/dmd/issues/18469
// CTFE: string ~= dchar rejected if string was initialized with an array literal
bool bug()
{
    string r = ['x', 'q'];
    dchar c = 'ü';
    r ~= c;
    assert(r == "xqü");
    return true;
}

static assert(bug());
void main() {}
