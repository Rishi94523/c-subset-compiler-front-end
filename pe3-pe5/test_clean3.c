typedef int MyInt;
static int global_var = 10;
extern double external_pi;

int add(int a, float b) {
    int result;
    result = a + b;
    return result;
}

static void process(int len) {
    int i;
    register int j;
    j = 0;
    for (i = 0; i < len; i++) {
        j = j + i;
    }
    {
        int inner;
        inner = j * 2;
        inner = inner + global_var;
    }
}

int main(void) {
    int x;
    int y;
    float arr[10];
    MyInt m;
    m = 42;
    add(x, 3);
    process(x);
    return 0;
}
