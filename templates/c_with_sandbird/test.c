#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "sandbird.h"

static int event_handler(sb_Event *e) {
    if (e->type == SB_EV_REQUEST) {
        printf("request:addr:[%s],method:[%s],path:[%s]\n", e->address, e->method, e->path);
        sb_send_status(e->stream, 200, "OK");
        sb_send_header(e->stream, "Content-Type", "text/plain");
        sb_writef(e->stream, "Hello world!");
    }
    return SB_RES_OK;
}

int main() {
    sb_Options opt;
    memset(&opt, 0, sizeof(opt));
    opt.port = "8000";
    opt.handler = event_handler;
    sb_Server *server = sb_new_server(&opt);
    printf("server running at: http://localhost:%s\n", opt.port);
    while (1) sb_poll_server(server, 1000);
    sb_close_server(server);
    return EXIT_SUCCESS;
}
