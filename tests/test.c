
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>

#define TEST_INCBIN
// #define TEST_THREAD
// #define TEST_MD5
// #define TEST_BASE64
// #define TEST_TAR
// #define TEST_CORO
// #define TEST_LUA
// #define TEST_TIGR
// #define TEST_RAYLIB
// #define TEST_WEBVIEW
// #define TEST_STB
// #define TEST_BMP
// #define TEST_NAETT
// #define TEST_SANDBOX

////////////////////////////////////////////////////////////////////////////////

// incbin
#ifdef TEST_INCBIN
#include "incbin.h"
void run_incbin() {
    printf("\nincbin.start:\n");
    INCBIN(Dynamic, "../resources/test.txt");
    printf("incbin.txt:%s\n", gDynamicData);
    printf("incbin.end!\n");
}
#endif

////////////////////////////////////////////////////////////////////////////////

// thread
#ifdef TEST_THREAD
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
#endif

////////////////////////////////////////////////////////////////////////////////

// md5
#ifdef TEST_MD5
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
#endif

////////////////////////////////////////////////////////////////////////////////

// base64
#ifdef TEST_BASE64
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
#endif

////////////////////////////////////////////////////////////////////////////////

// tar
#ifdef TEST_TAR
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
#endif

////////////////////////////////////////////////////////////////////////////////

// coro
#ifdef TEST_CORO
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
#endif

////////////////////////////////////////////////////////////////////////////////

// lua
#ifdef TEST_LUA
#define LUA_IMPL
#define LUAA_LUAIMPLEMENTATION
#include "minilua.h"
#include "lautoc.c"
int lua_my_fib(int n) {
    if (n == 0) { return 0; }
    if (n == 1) { return 1; }
    return lua_my_fib(n-1) + lua_my_fib(n-2);
}
int lua_my_call(lua_State* L) {
    char *name = lua_tostring(L, 1);
    return luaA_call_name(L, name);
}
void run_lua() {
    printf("\nlua.start:\n");
    INCBIN(Script, "../resources/test.lua");
    // 
    lua_State *L = luaL_newstate();
    if(L == NULL) return -1;
    //
    luaA_open(L);
    luaA_function(L, lua_my_fib, int, int);
    lua_register(L, "lua_my_call", lua_my_call);
    //
    luaL_openlibs(L);
    luaL_loadstring(L, gScriptData);
    lua_call(L, 0, 0);
    //
    luaA_close(L);
    lua_close(L);
    printf("lua.end!\n");
}
#endif

////////////////////////////////////////////////////////////////////////////////

// tigr
#ifdef TEST_TIGR
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
#endif

////////////////////////////////////////////////////////////////////////////////

// raylib
#ifdef TEST_RAYLIB
#include "raylib.h"
#define RAYGUI_IMPLEMENTATION
#include "raygui.h"
void run_raylib() {
    printf("\nraylib.start:\n");
    Rectangle button_rect = { 150, 150, 175, 75 };
    InitWindow(500, 500, "raylib...");
    SetTargetFPS(60);
    while (!WindowShouldClose())
    {
        BeginDrawing();
        ClearBackground(RAYWHITE);
        // 
        if(GuiButton(button_rect, "Click me!")) {
            printf("raylib.pressed!\n");
        }
        // 
        DrawText("hello...", 30, 30, 36, LIGHTGRAY);
        EndDrawing();
    }
    CloseWindow();
    printf("raylib.end!\n");
}
#endif

////////////////////////////////////////////////////////////////////////////////

// webview
#ifdef TEST_WEBVIEW
#define WEBVIEW_IMPLEMENTATION
#include "webview.h"
static void webview_callback(struct webview *w, const char *arg) {
  printf("Callback called with '%s'\n", arg);
}
void run_webview() {
    printf("\nwebview.start:\n");
    //
    INCBIN(Html, "../resources/test.html");
    char* content = malloc(1024 * 10);
    sprintf(content, "data:text/html,%s", gHtmlData);
    // 
    struct webview webview;
    memset(&webview, 0, sizeof(webview));
    webview.title = "title";
    webview.url = content;
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
#endif

////////////////////////////////////////////////////////////////////////////////

// stb
#ifdef TEST_STB
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
#endif

////////////////////////////////////////////////////////////////////////////////

// bmp
#ifdef TEST_BMP
#include "libbmp.h"
void run_bmp() {
    printf("\nbmp.start:\n");
    char *path = "../resources/test.bmp";
    // 
	bmp_img img;
    int width = 128;
    int height = 128;
    printf("bmp.write:%d*%d\n", width, height);
	bmp_img_init_df (&img, width, height);
	for (size_t y = 0, x; y < height; y++) {
		for (x = 0; x < width; x++) {
            unsigned char r = x % 255;
            unsigned char g = y % 255;
            unsigned char b = (r + g) % 128;
			bmp_pixel_init (&img.img_pixels[y][x], r, g, b);
		}
	}
	bmp_img_write (&img, path);
	bmp_img_free (&img);
    // 
    printf("bmp.end!\n");
}
#endif

////////////////////////////////////////////////////////////////////////////////

// naett
#ifdef TEST_NAETT
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
#endif

////////////////////////////////////////////////////////////////////////////////

// sandbird
#ifdef TEST_SANDBOX
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
#endif

////////////////////////////////////////////////////////////////////////////////

int main(int argc, char **argv)
{

    #ifdef TEST_INCBIN
    run_incbin();
    #endif

    #ifdef TEST_THREAD
    run_thread();
    #endif

    #ifdef TEST_MD5
    run_md5();
    #endif

    #ifdef TEST_BASE64
    run_base64();
    #endif

    #ifdef TEST_TAR
    run_tar();
    #endif

    #ifdef TEST_CORO
    run_coro();
    #endif

    #ifdef TEST_LUA
    run_lua();
    #endif

    #ifdef TEST_TIGR
    run_tigr();
    #endif

    #ifdef TEST_RAYLIB
    run_raylib();
    #endif

    #ifdef TEST_WEBVIEW
    run_webview();
    #endif

    #ifdef TEST_STB
    run_stb();
    #endif

    #ifdef TEST_BMP
    run_bmp();
    #endif

    #ifdef TEST_NAETT
    run_naett();
    #endif

    #ifdef TEST_SANDBOX
    run_sandbird();
    #endif

}
