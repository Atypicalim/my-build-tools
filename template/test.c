// #include <stdio.h>

// int main(int argc, char** argv)
// {
//     printf("hello world!\n");
//     #ifdef RAYLIB
//         printf("RAYLIB....");
//     #endif // DEBUG
//     return 0;
// }

// #include <stdio.h>
// #include "raylib.h"
// int main(void)
// {
//     InitWindow(800, 450, "raylib [core] example - basic window");

//     while (!WindowShouldClose())
//     {
//         BeginDrawing();
//             ClearBackground(RAYWHITE);
//             DrawText("Congrats! You created your first window!", 190, 200, 20, LIGHTGRAY);
//         EndDrawing();
//     }

//     CloseWindow();

//     return 0;
// }

#include "tigr.c"

int main(int argc, char *argv[])
{
    Tigr *screen = tigrWindow(320, 240, "Hello", 0);
    while (!tigrClosed(screen))
    {
        tigrClear(screen, tigrRGB(0x80, 0x90, 0xa0));
        tigrPrint(screen, tfont, 120, 110, tigrRGB(0xff, 0xff, 0xff), "Hello, world.");
        tigrUpdate(screen);
    }
    tigrFree(screen);
    return 0;
}
