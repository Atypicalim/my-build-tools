
#include "raylib.h"

int main(void)
{
    InitWindow(500, 500, "raylib [core] example - basic window");
    SetTargetFPS(60);
    while (!WindowShouldClose())
    {
        BeginDrawing();
        ClearBackground(RAYWHITE);
        DrawText("hello...", 30, 30, 36, LIGHTGRAY);
        EndDrawing();
    }
    CloseWindow();
    return 0;
}
