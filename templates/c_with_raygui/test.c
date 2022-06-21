#include "raylib.h"

#define RAYGUI_IMPLEMENTATION
#include "raygui.h"

int main()
{

    bool exitWindow = false;
    SetConfigFlags(FLAG_WINDOW_UNDECORATED);
    InitWindow(500, 500, "raygui - portable window");
    SetTargetFPS(60);

    while (!exitWindow && !WindowShouldClose())
    {
        BeginDrawing();
        ClearBackground(RAYWHITE);
        exitWindow = GuiWindowBox((Rectangle){ 0, 0, 300, 300 }, "#198# PORTABLE WINDOW");  
        DrawText("test...", 10, 40, 10, DARKGRAY);
        EndDrawing();
    }
    CloseWindow();
    return 0;
}