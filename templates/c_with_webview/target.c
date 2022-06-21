




#define WEBVIEW_IMPLEMENTATION
#include "webview.h"

char HTML_CODE[] = "data:text/html,<!DOCTYPE html> \n <html lang=\"en\"> \n <head> \n     <meta charset=\"UTF-8\"> \n     <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\"> \n     <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"> \n     <title>Document</title> \n </head> \n <body style=\"padding: 0px; margin: 0px; top:0px; background-color: aquamarine;\" onclick=\"window.external.invoke(\'Hi\')\"> \n     <div style=\"width: 510px;height: 510px;background-image: linear-gradient(rgb(23, 128, 177), rgb(9, 177, 51), rgb(116, 23, 179)); padding: 0px;\"> \n         <div id=\"box\" style=\"padding: 0px; margin: 0 auto; background-color: rgba(255, 4, 4, 0.541); border-radius: 100px; width: 200px; height: 200px; display: inline-block;\"> \n         </div> \n         <div style=\"padding: 15px;\"> \n             <p contenteditable>Edit Me ...</p> \n         </div> \n     </div> \n </body> \n <style> \n     * { \n         padding: 0px; \n         margin: 0px; \n     } \n     p { \n         color:rgb(212, 13, 202); \n         font-size: 30px; \n         line-height: 35px; \n         text-shadow: 2px 2px #dbeb03; \n     } \n </style> \n <script> \n     var d = document.getElementById(\"box\"); \n     d.style.position = \"absolute\"; \n     var x = 100; \n     var y = 100; \n     var xd = 1; \n     var yd = 2; \n     setInterval(function() { \n         x = x + xd; \n         y = y + yd; \n         if (x < 0 ) xd = 1; \n         if (x > 300 ) xd = -1; \n         if (y < 0 ) yd = 2; \n         if (y > 300 ) yd = -2; \n         d.style.left = x + \"px\"; \n         d.style.top = y + \"px\"; \n     }, 10); \n </script> \n </html>"; 

static void invoke_cb(struct webview *w, const char *arg) {
  printf("Callback called with '%s'\n", arg);
}

int main(int argc, char *argv[])
{
    struct webview webview;
    memset(&webview, 0, sizeof(webview));
    webview.title = "title";
    webview.url = HTML_CODE;
    webview.width = 500;
    webview.height = 500;
    webview.resizable = FALSE;
    webview.debug = TRUE;
    webview.external_invoke_cb = &invoke_cb;
    int r = webview_init(&webview);
    do {
        r = webview_loop(&webview, 1);
    } while (r == 0);
    webview_exit(&webview);
    return 0;
}
