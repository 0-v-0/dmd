enum foo17749(alias sym) = 3;

string str17749;

static assert(foo17749!str17749 == 3);

enum bar17749(int n) = 2;
enum bar17749(alias sym) = 3;

static assert(bar17749!str17749 == 3);
