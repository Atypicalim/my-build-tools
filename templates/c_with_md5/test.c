
#include <stdio.h>
#include <string.h>

#include "md5.h"

void print_hash(uint8_t *p){
	for(unsigned int i = 0; i < 16; ++i){
		printf("%02x", p[i]);
	}
	printf("\n");
}

int main(int argc, char **argv)
{
    printf("\nmd5:\n");
    uint8_t *txt1 = md5String("md5 string test ...");
    uint8_t *txt2 = md5File(fopen("./test.txt", "r"));
    printf("string:\n");
    print_hash(txt1);
    printf("file:\n");
    print_hash(txt2);
    printf("end!\n");
}

#include <stdio.h>
