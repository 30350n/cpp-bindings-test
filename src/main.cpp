#include <iostream>

extern "C" int hello(int num)
{
    std::cout << "Hello " << num << std::endl;
    return 0;
}
