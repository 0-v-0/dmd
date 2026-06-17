void main()
{
    Object a;
    Object b;
    synchronized (a = b, b = a)
    {
    }
}
