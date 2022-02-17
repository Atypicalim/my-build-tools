




#define WEBVIEW_IMPLEMENTATION
//don't forget to define WEBVIEW_WINAPI,WEBVIEW_GTK or WEBVIEW_COCAO
#define WEBVIEW_WINAPI
#include "webview.h"

// html code in js string and js code is in c string, so we need "\\" to escape twice
char HTML_CODE[] = "document.documentElement.innerHTML = '<!DOCTYPE html>  \\\n <html lang=\\\"en\\\">  \\\n <head>  \\\n     <meta charset=\\\"UTF-8\\\">  \\\n     <meta http-equiv=\\\"X-UA-Compatible\\\" content=\\\"IE=edge\\\">  \\\n     <meta name=\\\"viewport\\\" content=\\\"width=device-width, initial-scale=1.0\\\">  \\\n     <title>Document</title>  \\\n </head>  \\\n <body style=\\\"padding: 0px; margin: 0px; top:0px; background-color: aquamarine;\\\">  \\\n     <div style=\\\"width: 100%;height: 510px;background-image: linear-gradient(rgb(23, 128, 177), rgb(9, 177, 51), rgb(116, 23, 179)); padding: 0px;\\\">  \\\n         <div id=\\\"box\\\" style=\\\"padding: 0px; margin: 0 auto; background-color: rgba(255, 4, 4, 0.541); border-radius: 50%; width: 200px; height: 200px; display: inline-block;\\\">  \\\n         </div>  \\\n         <div style=\\\"padding: 15px;\\\">  \\\n             <p contenteditable>Edit Me ...</p>  \\\n         </div>  \\\n     </div>  \\\n </body>  \\\n <style>  \\\n     * {  \\\n         padding: 0px;  \\\n         margin: 0px;  \\\n     }  \\\n     p {  \\\n         color:rgb(212, 13, 202);  \\\n         font-size: 30px;  \\\n         line-height: 35px;  \\\n         text-shadow: 2px 2px #dbeb03;  \\\n     }  \\\n </style>  \\\n <script>  \\\n     var d = document.getElementById(\\\"box\\\");  \\\n     d.style.position = \\\"absolute\\\";  \\\n     var x = 100;  \\\n     var y = 100;  \\\n     var xd = 1;  \\\n     var yd = 2;  \\\n     setInterval(function() {  \\\n         x = x + xd;  \\\n         y = y + yd;  \\\n         if (x < 0 ) xd = 1;  \\\n         if (x > 300 ) xd = -1;  \\\n         if (y < 0 ) yd = 2;  \\\n         if (y > 300 ) yd = -2;  \\\n         d.style.left = x + \\\"px\\\";  \\\n         d.style.top = y + \\\"px\\\";  \\\n     }, 10);  \\\n     // TODO: how to break there  \\\n     alert(\\\"OK\\\");  \\\n </script>  \\\n </html>';"; 
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
