#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>

#include "incbin.h"

#ifndef WINDOW_WIDTH
    #define WINDOW_WIDTH 500
#endif

#ifndef WINDOW_HEIGHT
    #define WINDOW_HEIGHT 500
#endif

#ifndef WINDOW_RESIZABLE
    #define WINDOW_RESIZABLE false
#endif

#define STRINGIFY(x) #x
#define MACRO(x)     STRINGIFY(x)

#ifndef WINDOW_TITLE
    #define WINDOW_TITLE "Unknown"
#endif

#define WEBVIEW_IMPLEMENTATION
#include "webview.h"
static void webview_callback(struct webview *w, const char *arg) {
    // js: window.external.invoke('Hi')
    printf("Callback called with '%s'\n", arg);
}
void run_webview() {
    //
    INCBIN(Html, "temporary.html");
    char* content = malloc(1024 * 10);
    sprintf(content, "data:text/html,%s", gHtmlData);
    // 
    struct webview webview;
    memset(&webview, 0, sizeof(webview));
    webview.title = MACRO(WINDOW_TITLE);
    webview.url = content;
    webview.width = WINDOW_WIDTH;
    webview.height = WINDOW_HEIGHT;
    webview.resizable = WINDOW_RESIZABLE;
    webview.debug = true;
    webview.external_invoke_cb = &webview_callback;
    int r = webview_init(&webview);
    do {
        r = webview_loop(&webview, 1);
    } while (r == 0);
    webview_exit(&webview);
    //
}

int main(void) {
    run_webview();
    return 0;
}
