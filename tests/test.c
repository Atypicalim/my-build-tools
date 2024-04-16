
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>


char HTML_CODE[] = "data:text/html,%s"; // [M[ FILE_STRING | ../resources/test.html ]M]

////////////////////////////////////////////////////////////////////////////////

// thread
#include "tinycthread.c"
int _thread_body(void *aArg)
{
    printf("thread.working:%d\n", *(int*)aArg);
    sleep(1);
}
void run_thread() {
    printf("\nthread.start:\n");
    for (size_t i = 0; i < 3; i++)
    {
        thrd_t t;
        void *arg = malloc(sizeof(int));
        arg = &i;
        thrd_create(&t, _thread_body, arg);
        thrd_join(t, NULL);
    }
    printf("thread.end!\n");
}

////////////////////////////////////////////////////////////////////////////////

// md5
#include "md5.h"
void _md5_print(uint8_t *p){
	for(unsigned int i = 0; i < 16; ++i){
		printf("%02x", p[i]);
	}
	printf("\n");
}
void run_md5()
{
    printf("\nmd5.start:\n");
    uint8_t txt1[1024];
    uint8_t txt2[1024];
    printf("md5.string:\n");
    md5String("test ...", txt1);
    _md5_print(txt1);
    md5File(fopen("../resources/test.txt", "r"), txt2);
    printf("md5.file:\n");
    _md5_print(txt2);
    printf("md5.end!\n");
}

////////////////////////////////////////////////////////////////////////////////

// base64
#include "base64.c"
void run_base64()
{
    printf("\nbase64.start:\n");
    char *originText = "hello base64 ...";
    char *encodedText = base64_encode(originText);
    char *decodedText = base64_decode(encodedText);
    printf("base64.origin:%s\n", originText);
    printf("base64.encoded:%s\n", encodedText);
    printf("base64.decoded:%s\n", decodedText);
    free(encodedText);
    free(decodedText);
    printf("base64.end!\n");
}

////////////////////////////////////////////////////////////////////////////////

// tar
#include "microtar.h"
void run_tar() {
    printf("\ntar.start:\n");
    mtar_t tar;
    const char *tarName = "./test.tar";
    const char *txtName = "test.txt";
    // 
    const char *str = "hello...";
    mtar_open(&tar, tarName, "w");
    mtar_write_file_header(&tar, txtName, strlen(str));
    mtar_write_data(&tar, str, strlen(str));
    mtar_finalize(&tar);
    mtar_close(&tar);
    //
    char *txt = calloc(1, 1024);
    mtar_header_t head;
    mtar_open(&tar, tarName, "r");
    mtar_find(&tar, txtName, &head);
    mtar_read_data(&tar, txt, head.size);
    mtar_close(&tar);
    printf("tar.txt:%s\n", txt);
    //
    printf("tar.end!\n");
}

////////////////////////////////////////////////////////////////////////////////

// coro
#define MINICORO_IMPL
#include "minicoro.h"
void _coro_body(mco_coro *co)
{
    printf("coro.running1\n");
    mco_yield(co);
    printf("coro.running2\n");
}
void run_coro() {
    printf("\ncoro.start:\n");
    mco_desc desc = mco_desc_init(_coro_body, 0);
    mco_coro *co;
    mco_create(&co, &desc);
    printf("coro.starting:\n");
    mco_resume(co);
    printf("coro.resumed.\n");
    assert(mco_status(co) == MCO_SUSPENDED);
    printf("coro.starting:\n");
    mco_resume(co);
    assert(mco_status(co) == MCO_DEAD);
    printf("coro.resumed.\n");
    mco_destroy(co);
    printf("coro.end!\n");
}

////////////////////////////////////////////////////////////////////////////////

// incbin
#include "incbin.h"
void run_incbin() {
    printf("\nincbin.start:\n");
    INCBIN(Dynamic, "../resources/test.txt");
    printf("incbin.txt:%s\n", gDynamicData);
    printf("incbin.end!\n");
}

////////////////////////////////////////////////////////////////////////////////

// tigr
#include "tigr.c"
void run_tigr() {
    printf("\ntigr.start:\n");
    Tigr *screen = tigrWindow(320, 240, "Hello", 0);
    while (!tigrClosed(screen))
    {
        tigrClear(screen, tigrRGB(0x80, 0x90, 0xa0));
        tigrPrint(screen, tfont, 120, 110, tigrRGB(0xff, 0xff, 0xff), "hello...");
        tigrUpdate(screen);
    }
    tigrFree(screen);
    printf("tigr.end!\n");
}

////////////////////////////////////////////////////////////////////////////////

// webview
#define WEBVIEW_IMPLEMENTATION
#include "webview.h"
static void webview_callback(struct webview *w, const char *arg) {
  printf("Callback called with '%s'\n", arg);
}
void run_webview() {
    printf("\nwebview.start:\n");
    //
    INCBIN(Html, "../resources/test.html");
    char* t = malloc(1024 * 10);
    sprintf (t, "data:text/html,%s", gHtmlData);
    // 
    struct webview webview;
    memset(&webview, 0, sizeof(webview));
    webview.title = "title";
    webview.url = t;
    webview.width = 550;
    webview.height = 550;
    webview.resizable = FALSE;
    webview.debug = TRUE;
    webview.external_invoke_cb = &webview_callback;
    int r = webview_init(&webview);
    do {
        r = webview_loop(&webview, 1);
    } while (r == 0);
    webview_exit(&webview);
    //
    printf("webview.end!\n");
}

////////////////////////////////////////////////////////////////////////////////

// stb
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"
void run_stb() {
    printf("\nstb.start:\n");
    char *input = "../resources/test.jpg";
    char *out = "./test.png";
    //
    int width, height, channels;
    unsigned char *data = stbi_load(input, &width, &height, &channels, 0);
    if (!data) {
        printf("stb.read [%s] failed!\n", input);
        return 1;
    }
    //
    printf("stb.read:%s\n", input);
    printf("stb.width: %d\n", width);
    printf("stb.height: %d\n", height);
    printf("stb.channels: %d\n", channels);
    unsigned bytePerPixel = channels;
    for (int x = 0; x < 100; x++) {
        for (int y = 0; y < 100; y++) {
            int offset = channels * (y * width + x);
            data[offset + 0] = 0;
            data[offset + 1] = data[offset + 1] / 1;
            data[offset + 2] = data[offset + 2] / 2;
        }
    }
    //
    stbi_write_png(out, width, height, channels, data, width * channels);
    stbi_image_free(data);
    printf("stb.write:%s\n", out);
    printf("stb.end!\n");
}

////////////////////////////////////////////////////////////////////////////////

// naett
#include "naett.c"
void run_naett() {
    printf("\naett.start:\n");
    //
    naettInit(NULL);
    naettReq* req = naettRequest("http://ip.jsontest.com/", naettMethod("GET"), naettHeader("accept", "*/*"));
    naettRes* res = naettMake(req);
    //
    while (!naettComplete(res)) {
        usleep(100 * 1000);
    }
    if (naettGetStatus(res) < 0) {
        printf("naett.failed!\n");
        return 1;
    }
    int bodyLength = 0;
    const char* body = naettGetBody(res, &bodyLength);
    //
    printf("naett.Header-> '%s'\n", naettGetHeader(res, "Content-Type"));
    printf("naett.Length-> %d bytes\n", bodyLength);
    printf("naett.body:%s\n", body);
    printf("naett.end!\n");
}

////////////////////////////////////////////////////////////////////////////////

// sandbird
#include "sandbird.h"
static int sandbird_handler(sb_Event *e) {
    if (e->type == SB_EV_REQUEST) {
        printf("request:addr:[%s],method:[%s],path:[%s]\n", e->address, e->method, e->path);
        sb_send_status(e->stream, 200, "OK");
        sb_send_header(e->stream, "Content-Type", "text/plain");
        sb_writef(e->stream, "Hello world!");
    }
    return SB_RES_OK;
}
void run_sandbird() {
    printf("\nsandbird.start:\n");
    sb_Options opt;
    memset(&opt, 0, sizeof(opt));
    opt.port = "8000";
    opt.handler = sandbird_handler;
    sb_Server *server = sb_new_server(&opt);
    printf("sandbird.addr: http://localhost:%s\n", opt.port);
    while (1) sb_poll_server(server, 1000);
    sb_close_server(server);
    printf("sandbird.end!\n");
}

////////////////////////////////////////////////////////////////////////////////

int main(int argc, char **argv)
{
    // run_thread();
    // run_base64();
    // run_md5();
    // run_tar();
    // run_coro();
    // run_incbin();
    // run_tigr();
    // run_webview();
    // run_stb();
    // run_naett();
    // run_sandbird();
}
