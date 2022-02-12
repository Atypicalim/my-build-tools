--[[
    configs
]]

CONFIGS = {
    -- Single-file port of Lua, a powerful scripting language.
    ["minilua"] = {
        [KEYS.URL] = "https://github.com/edubart/minilua.git",
        [KEYS.BRANCH] = "main",
        [KEYS.DIR_I] = "./",
    },
    -- Automagically use C Functions and Structs with the Lua API
    ["luaauto"] = {
        [KEYS.URL] = "https://github.com/orangeduck/LuaAutoC.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = "./",
    },
    -- Single header asymmetric stackful cross-platform coroutine library in pure C.
    ["minicoro"] = {
        [KEYS.URL] = "https://github.com/edubart/minicoro.git",
        [KEYS.BRANCH] = "main",
        [KEYS.DIR_I] = "./",
    },
    -- Single file audio playback and capture library written in C.
    ["miniaudio"] = {
        [KEYS.URL] = "https://github.com/mackron/miniaudio.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = "./",
    },
    -- the TIny GRaphics library for Windows, macOS, Linux, iOS and Android.
    ["tigr"] = {
        [KEYS.URL] = "https://github.com/erkkah/tigr.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = "./",
        [KEYS.LIB_L] = {"opengl32", "gdi32"},
    },
    -- A simple and easy-to-use library to enjoy videogames programming
    ["raylib"] = {
        [KEYS.URL] = "https://github.com/raysan5/raylib/releases/download/4.0.0/raylib-4.0.0_win64_mingw-w64.zip",
        [KEYS.DIR_I] = "raylib-4.0.0_win64_mingw-w64/include/",
        [KEYS.DIR_L] = "raylib-4.0.0_win64_mingw-w64/lib/",
        [KEYS.LIB_L] = {"raylib", "opengl32", "gdi32", "winmm"},
    },
    -- A simple and easy-to-use immediate-mode gui library
    ["raygui"] = {
        [KEYS.URL] = "https://github.com/raysan5/raygui/archive/refs/tags/3.1.zip",
        [KEYS.DIR_I] = "./raygui-3.1/",
    },
    -- A tiny cross-platform webview C library to build modern cross-platform GUIs
    ["webview"] = {
        [KEYS.URL] = "https://github.com/javalikescript/webview-c.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = {"./", "./ms.webview2/include"},
        [KEYS.LIB_L] = {"ole32", "comctl32", "oleaut32", "uuid", "gdi32"},
        [KEYS.FLAGS] = "-DWEBVIEW_WINAPI=1",
    },
    -- A simple logging library implemented in C99
    ["log"] = {
        [KEYS.URL] = "https://github.com/rxi/log.c.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = "./src/",
    },
    -- A Tiny Garbage Collector for C
    ["tgc"] = {
        [KEYS.URL] = "https://github.com/orangeduck/tgc.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = "./",
    },
    -- A tiny ANSI C library for loading .ini config files
    ["ini"] = {
        [KEYS.URL] = "https://github.com/rxi/ini.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = "./src/",
    },
    -- Dynamic memory tracker for C
    ["dmt"] = {
        [KEYS.URL] = "https://github.com/rxi/dmt.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = "./src/",
        [KEYS.FLAGS] = " -Wall",
    },
    -- A tiny C library for generating uuid4 strings
    ["uuid4"] = {
        [KEYS.URL] = "https://github.com/rxi/uuid4.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = "./src/",
    },
    -- tiny file dialogs
    ["tinyfiledialogs"] = {
        [KEYS.URL] = "https://github.com/native-toolkit/tinyfiledialogs.git",
        [KEYS.BRANCH] = "master",
        [KEYS.LIB_L] = {"comdlg32", "ole32"},
        [KEYS.DIR_I] = "./",
    },
    -- (Keep It) Simple Stupid Database
    ["kissdb"] = {
        [KEYS.URL] = "https://github.com/adamierymenko/kissdb.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = "./",
    },
    -- Lightweight JSON library written in C.
    ["parson"] = {
        [KEYS.URL] = "https://github.com/kgabis/parson.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = "./",
    },
    -- single header utf8 string functions for C and C++
    ["utf8"] = {
        [KEYS.URL] = "https://github.com/sheredom/utf8.h.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = "./",
    },
}