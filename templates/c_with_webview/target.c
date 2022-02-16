




#define WEBVIEW_IMPLEMENTATION
//don't forget to define WEBVIEW_WINAPI,WEBVIEW_GTK or WEBVIEW_COCAO
#define WEBVIEW_WINAPI
#include "webview.h"

char HTML_CODE[] = "document.documentElement.innerHTML = '<!DOCTYPE html>  <html lang=\"en\">  <head>      <meta charset=\"UTF-8\">      <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">      <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">      <title>Document</title>  </head>  <body style=\"padding: 0px; margin: 0px;width: 100%; height: 100%; background-color: cadetblue;\">      <h1>Hello...</h1>      <div id=\"box\" style=\"margin: 0 auto; background-color: blueviolet; border-radius: 50%; width: 200px; height: 200px; display: inline-block;\">      </div>  </body>  <script type=\"text/javascript\">      // TODO      var d = document.getElementById(\"box\");      d.style.position = \"absolute\";      d.style.backgroundColor = \"green\";      var x = 100;      var y = 100;      setInterval(function() {          x = x + 100;          d.style.left = x + \"px\";          d.style.top = y + \"px\";      }, 1);        alert();    </script>  </html>';"; 


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
    while (webview_loop(&webview, 1) == 0) {
    }
    webview_exit(&webview);
    return 0;
}
