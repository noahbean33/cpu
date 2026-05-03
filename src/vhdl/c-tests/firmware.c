

#include <stdint.h>
#include <stdbool.h>



int f (int a, int b, int c)
{
    int tmp1;
    int tmp2;
    tmp1 = a + b;
    tmp2 = tmp1 + c;
    return tmp2;
}

void main()
{

	int var;

    var = f(1,2,3);


}
