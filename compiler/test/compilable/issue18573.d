struct S
{
    float value = 0.0f;
    alias value this;
}

enum S es = 250.0;
static assert(es.value == 250.0f);

immutable S si = 125.0;
static assert(si.value == 125.0f);

S s = 250.0;

void main()
{
}
