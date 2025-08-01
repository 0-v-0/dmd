import core.stdc.stdio;
import core.stdc.stdlib;

/*************************************************/

struct S
{
    float d;
    int i;
    char c;
}

void test1()
{
    S s;
    S* p = new (s) S();
    assert(p.i == 0 && p.c == 0xFF);
}

void test2()
{
    S s;
    S* p = new (s) S(i:3);
    assert(p.i == 3 && p.c == 0xFF);
}

/*************************************************/

struct S3
{
    int i;
    this(int i) { this.i = i + 3; }
}

void test3()
{
    S3 s;
    s.i = 20;
    S3* p = new (s) S3(4);
    assert(p.i == 7);
}


/*************************************************/

void test4()
{
    int i = 3;
    int* p = new(i) int;
    *p = 4;
    assert(i == 4);

    p = new(i) int(7);
    assert(i == 7);
}

/*************************************************/

class C5
{
    int i, j = 4;
}

int test5()
{
    int[10] k;
    C5 c = new(k) C5;
    //printf("c.j: %d\n", c.j);
    assert(c.j == 4);
    assert(cast(void*)c == cast(void*)k.ptr);
    return c.j;
}

/*************************************************/

struct S6
{
    int i = 1, j = 4, k = 9;
}

ref void[T.sizeof] mallocate(T)()
{
    return *(cast(void[T.sizeof]*) malloc(T.sizeof));
}

void test6()
{
    S6* ps = new(mallocate!S6()) S6;
    assert(ps.i == 1);
    assert(ps.j == 4);
    assert(ps.k == 9);
}

/*************************************************/

struct S7
{
    int x = 10;
    int y = 20;
}

void test7()
{
    S7 t = void;
    new (t) S7(10,20);
    assert(t.x == 10 && t.y == 20);
}

/*************************************************/
// https://github.com/dlang/dmd/issues/21203

struct Y8
{
    int a;
    this() @disable; // default disabled
    this(int i) { a = i; }
}

struct S8
{
    Y8 m;

    this(int x)
    {
        new(m) Y8(x); // initialise `m`
    }
}

void test8()
{
    S8 s = S8(3);
    assert(s.m.a == 3);
}

/*************************************************/
// https://github.com/dlang/dmd/issues/21549

struct Test9
{
    size_t a, b = 3;
    this(int x)
	{
		a = x;
	}
}

void new9(ref Test9 p)
{
    new(p) Test9(1);
}

void test9()
{
	Test9 t9 = void;
	new9(t9);
	assert(t9.a == 1);
	// assert(t9.b == 3);  // Test9.init not copied yet
}

/*************************************************/

int main()
{
    test1();
    test2();
    test3();
    test4();
    test5();
    test6();
    test7();
    test8();
    test9();

    return 0;
}
