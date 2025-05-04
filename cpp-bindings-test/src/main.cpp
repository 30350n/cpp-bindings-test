#include <stdio.h>

extern "C" int hello(int num)
{
    printf("Hello %d\n", num);
    fflush(stdout);
    return 0;
}
