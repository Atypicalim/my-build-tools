
#include <stdio.h>
#include <string.h>

#define MINICORO_IMPL
#include "minicoro.h"
void coro_entry(mco_coro *co)
{
    printf("coroutine 1\n");
    mco_yield(co);
    printf("coroutine 2\n");
}

int main(int argc, char **argv)
{
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
}
