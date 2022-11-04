
#include <stdio.h>
#include <string.h>

#include <tinycthread.c>
int thread_entry(void * aArg)
{
    printf("working:%d\n", (int)aArg);
    sleep(1);
}

int main(int argc, char **argv)
{
    printf("\nthread:\n");
    for (size_t i = 0; i < 5; i++)
    {
        thrd_t t;
        thrd_create(&t, thread_entry, (void*)i);
        thrd_join(t, NULL);
    }
    printf("end!\n");
}
