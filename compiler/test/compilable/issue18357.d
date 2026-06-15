enum int[1] array1 = [10];
int foo(int[1] v)
{
    return array1[0] * v[0];
}

const int[1] array2 = [10];
int bar(int[1] v)
{
    return array2[0] * v[0];
}

void main()
{
}
