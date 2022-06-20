#include "naett.c"
#include <unistd.h>
#include <stdio.h>

int main(int argc, char** argv) {

    naettInit(NULL);
    naettReq* req = naettRequest("http://ip.jsontest.com/", naettMethod("GET"), naettHeader("accept", "*/*"));
    naettRes* res = naettMake(req);

    while (!naettComplete(res)) {
        usleep(100 * 1000);
    }

    if (naettGetStatus(res) < 0) {
        printf("Request failed\n");
        return 1;
    }

    int bodyLength = 0;
    const char* body = naettGetBody(res, &bodyLength);

    printf("Header-> '%s'\n", naettGetHeader(res, "Content-Type"));
    printf("Length-> %d bytes\n", bodyLength);
    printf("%.24s\n...\n", body);
}
