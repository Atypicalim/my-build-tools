
#include "microtar.h"
#include <string.h>

int main(int argc, char *argv[])
{
    // 
    mtar_t tar;
    mtar_header_t h;
    char *p = calloc(1, 1024);
    const char *tarName = "test.tar";
    const char *txtName = "test.txt";
    const char *str = "hello...";
    mtar_open(&tar, tarName, "rw");
    //
    mtar_write_file_header(&tar, txtName, strlen(str));
    mtar_write_data(&tar, str, strlen(str));
    mtar_finalize(&tar);
    //
    mtar_find(&tar, txtName, &h);
    mtar_read_data(&tar, p, h.size);
    printf("content:%s", p);
    //
    mtar_close(&tar);
    return 0;
}
