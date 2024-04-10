
#include <stdio.h>
#include <string.h>

#include "incbin.h"

int main(int argc, char **argv)
{
    INCBIN(Dynamic, "./test.txt");
    printf("%s\n", gDynamicData);
}
