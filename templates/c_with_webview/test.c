
#define WEBVIEW_IMPLEMENTATION
//don't forget to define WEBVIEW_WINAPI,WEBVIEW_GTK or WEBVIEW_COCAO
#define WEBVIEW_WINAPI
#include "webview.h"

// html code in js string and js code is in c string, so we need "\\" to escape twice
char HTML_CODE[] = "document.documentElement.innerHTML = '%s';"; // [M[ FILE_STRING | ./test.html | \\ ]M]
char JS_CODE[] = "var codes = document.getElementsByTagName(\"script\"); for(var i=0;i<codes.length;i++) { eval(codes[i].text); }";
// char JS_CODE[] = "alert(\"OK\")";

int main(int argc, char *argv[])
{

FILE *fp;
fp = fopen(".\/a.txt", "w");
if(fp == NULL) return 1;
fwrite(HTML_CODE, sizeof(HTML_CODE[0]), sizeof(HTML_CODE)/sizeof(HTML_CODE[0]), fp);
fclose(fp);

    struct webview webview;
    memset(&webview, 0, sizeof(webview));
    webview.title = "title";
    webview.url = "";
    webview.width = 500;
    webview.height = 500;
    webview.resizable = FALSE;
    int r = webview_init(&webview);
    if (r != 0) {
        return r;
    }
    webview_eval(&webview, HTML_CODE);
    webview_eval(&webview, JS_CODE);
    while (webview_loop(&webview, 1) == 0) {
    }
    webview_exit(&webview);
    return 0;
}
