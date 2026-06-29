abstract class Parent
{
    alias boop = beep;
    abstract string beep();
}

final class Child : Parent
{
    override string beep() { return "BEEP"; }
}

void main()
{
    auto x = (new Child()).boop;
}
