--[[
    configs
]]

CONFIGS = {
    ["minilua"] = {
        [KEYS.URL] = "https://github.com/edubart/minilua.git",
        [KEYS.BRANCH] = "main",
    },
    ["minicoro"] = {
        [KEYS.URL] = "https://github.com/edubart/minicoro.git",
        [KEYS.BRANCH] = "main",
    },
    ["tigr"] = {
        [KEYS.URL] = "https://github.com/erkkah/tigr.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = "./",
        [KEYS.LIB_L] = {"opengl32", "gdi32"},
    },
    ["raylib"] = {
        [KEYS.URL] = "https://github.com/raysan5/raylib/releases/download/4.0.0/raylib-4.0.0_win64_mingw-w64.zip",
        [KEYS.DIR_I] = "raylib-4.0.0_win64_mingw-w64/include/",
        [KEYS.DIR_L] = "raylib-4.0.0_win64_mingw-w64/lib/",
        [KEYS.LIB_L] = {"raylib", "opengl32", "gdi32", "winmm"},
    },
    ["webview"] = {
        [KEYS.URL] = "git@github.com:javalikescript/webview-c.git",
    },
}