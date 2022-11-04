
#include <stdio.h>
#include <string.h>

#include "base64.c"

int main(int argc, char **argv)
{
    printf("\nbase64:\n");
    char *originText = "hello base64 ...";
    char *encodedText = base64_encode(originText);
    char *decodedText = base64_decode(encodedText);
    printf("origin:%s\n", originText);
    printf("encoded:%s\n", encodedText);
    printf("decoded:%s\n", decodedText);
    free(encodedText);
    free(decodedText);
    printf("end!\n");
}
