




#define WEBVIEW_IMPLEMENTATION
//don't forget to define WEBVIEW_WINAPI,WEBVIEW_GTK or WEBVIEW_COCAO
#define WEBVIEW_WINAPI
#include "webview.h"

char HTML_CODE[] = "document.documentElement.innerHTML = '<!DOCTYPE html>  <html lang=\"en\">  <head>      <meta charset=\"UTF-8\">      <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">      <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">      <title>Document</title>  </head>  <body style=\"padding: 0px; margin: 0px; top:0px; background-color: aquamarine;\">      <div style=\"width: 100%;height: 510px;background-image: linear-gradient(rgb(23, 128, 177), rgb(9, 177, 51), rgb(116, 23, 179)); padding: 0px;\">          <div id=\"box\" style=\"padding: 0px; margin: 0 auto; background-color: rgba(255, 4, 4, 0.541); border-radius: 50%; width: 200px; height: 200px; display: inline-block;\">          </div>          <div style=\"padding: 15px;\">              <p contenteditable>Edit Me ...</p>          </div>      </div>  </body>  <style>      * {          padding: 0px;          margin: 0px;      }      p {          color:rgb(212, 13, 202);          font-size: 30px;          line-height: 30px;          text-shadow: 2px 2px #dbeb03;      }  </style>  <script>      var d = document.getElementById(\"box\");      d.style.position = \"absolute\";      var x = 100;      var y = 100;      var xd = 1;      var yd = 2;      setInterval(function() {          x = x + xd;          y = y + yd;          if (x < 0 ) xd = 1;          if (x > 300 ) xd = -1;          if (y < 0 ) yd = 2;          if (y > 300 ) yd = -2;          d.style.left = x + \"px\";          d.style.top = y + \"px\";      }, 10);  </script>  </html>';"; 
char JS_CODE[] = "var codes = document.getElementsByTagName(\"script\"); for(var i=0;i<codes.length;i++) { eval(codes[i].text); }";
// char JS_CODE[] = "alert(\"OK\")";

int main(int argc, char *argv[])
{
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
