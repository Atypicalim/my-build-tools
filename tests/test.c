
#include <stdio.h>
#include <string.h>
#include <unistd.h>

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

int main(int argc, char **argv)
{
    // run_thread();
    // run_base64();
    // run_md5();
    // run_tar();
    // run_coro();
    // run_incbin();
    // 1**4;
}
