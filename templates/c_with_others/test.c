
#include <stdio.h>
#include <string.h>

#include "base64.c"

#define MINICORO_IMPL
#include "minicoro.h"
void coro_entry(mco_coro *co)
{
    printf("coroutine 1\n");
    mco_yield(co);
    printf("coroutine 2\n");
}

#include <tinycthread.c>
int thread_entry(void * aArg)
{
    printf("working:%d\n", (int)aArg);
    sleep(1);
}

int main(int argc, char **argv)
{
    // base64
    printf("\nbase64:\n");
    char *originText = "hello base64 ...";
    char *encodedText = base64_encode(originText);
    char *decodedText = base64_decode(encodedText);
    printf("origin:%s\n", originText);
    printf("encoded:%s\n", encodedText);
    printf("decoded:%s\n", decodedText);
    free(encodedText);
    free(decodedText);
    printf("end!\n");
    // coroutine
    printf("\ncoroutine:\n");
    mco_desc desc = mco_desc_init(coro_entry, 0);
    mco_coro *co;
    printf("creating...\n");
    mco_create(&co, &desc);
    printf("starting:\n");
    mco_resume(co);
    printf("main...\n");
    assert(mco_status(co) == MCO_SUSPENDED);
    printf("resuming:\n");
    mco_resume(co);
    assert(mco_status(co) == MCO_DEAD);
    printf("destroying...\n");
    mco_destroy(co);
    printf("end!\n");
    // thread
    printf("\nthread:\n");
    for (size_t i = 0; i < 5; i++)
    {
        thrd_t t;
        thrd_create(&t, thread_entry, (void*)i);
        thrd_join(t, NULL);
    }
    printf("end!\n");

}

#include <stdio.h>
