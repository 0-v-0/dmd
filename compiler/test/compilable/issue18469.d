module issue18469;

bool bug()
{
    string r = ['x', 'q'];
    dchar c = '\u00FC';
    r ~= c;
    assert(r == "xq\u00FC");
    return true;
}

static assert(bug());
