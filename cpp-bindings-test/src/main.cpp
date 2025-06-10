#include <stdio.h>
#include <vector>

extern "C" int hello(int num)
{
    printf("Hello %d\n", num);
    fflush(stdout);
    return 0;
}

std::vector<int> a;

extern "C" std::vector<int> *foo()
{
    a.resize(20);
    for (int i = 0; i < 10; i++)
    {
        a.push_back(i);
    }
    return &a;
}
