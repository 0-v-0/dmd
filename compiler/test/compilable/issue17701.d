alias A = uint;
alias answer = 42;
alias again = answer;
alias truth = true;
alias text = "abc";
alias none = null;

static assert(answer == 42);
static assert(again == 42);
static assert(truth);
static assert(text == "abc");
static assert(none is null);

void main()
{
    A value = answer;
    assert(value == 42);
}
