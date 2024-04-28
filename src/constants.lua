
KEYS = {
    NAME = "NAME",
    TYPE = "TYPE",
    URL = "URL",
    EXT = "EXT",
    BRANCH = "BRANCH",
    DIR_I = "DIR_I", -- -I
    DIR_L = "DIR_L", -- -L
    LIB_L = "LIB_L", -- -l
    FLAGS = "FLAGS", -- flags
    FILES = "FILES", -- include source files in lib
    WIN = "WIN",
    LNX = "LNX",
    MAC = "MAC",
}
TYPES = {
    GIT = "GIT",
    ZIP = "ZIP",
    GZ = "GZ",
}
CONFIGS = {
    -- Single-file port of Lua, a powerful scripting language.
    ["minilua"] = {
        [KEYS.URL] = "git@github.com:edubart/minilua.git",
        [KEYS.BRANCH] = "main",
        [KEYS.DIR_I] = "./",
    },
    -- Automagically use C Functions and Structs with the Lua API
    ["luaauto"] = {
        [KEYS.URL] = "git@github.com:orangeduck/LuaAutoC.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = "./",
    },
    -- Single header asymmetric stackful cross-platform coroutine library in pure C.
    ["minicoro"] = {
        [KEYS.URL] = "git@github.com:edubart/minicoro.git",
        [KEYS.BRANCH] = "main",
        [KEYS.DIR_I] = "./",
    },
    -- Single file audio playback and capture library written in C.
    ["miniaudio"] = {
        [KEYS.URL] = "git@github.com:mackron/miniaudio.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = "./",
    },
    -- the TIny GRaphics library for Windows, macOS, Linux, iOS and Android.
    ["tigr"] = {
        [KEYS.URL] = "git@github.com:erkkah/tigr.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = "./",
        [KEYS.LIB_L] = {"opengl32", "gdi32"},
    },
    -- A simple and easy-to-use library to enjoy videogames programming
    ["raylib"] = {
        [KEYS.WIN] = {
            [KEYS.URL] = "https://github.com/raysan5/raylib/releases/download/4.0.0/raylib-4.0.0_win64_mingw-w64.zip",
            [KEYS.DIR_I] = "raylib-4.0.0_win64_mingw-w64/include/",
            [KEYS.DIR_L] = "raylib-4.0.0_win64_mingw-w64/lib/",
            [KEYS.LIB_L] = {"raylib", "opengl32", "gdi32", "winmm"},
        },
        [KEYS.MAC] = {
            [KEYS.URL] = "https://github.com/raysan5/raylib/releases/download/4.0.0/raylib-4.0.0_macos.tar.gz",
            [KEYS.DIR_I] = "raylib-4.0.0_macos/include/",
            [KEYS.DIR_L] = "raylib-4.0.0_macos/lib/",
            [KEYS.FLAGS] = " -lraylib -framework OpenGL -framework Cocoa -framework IOKit -framework CoreAudio -framework CoreVideo ",
        },
    },
    -- A simple and easy-to-use immediate-mode gui library
    ["raygui"] = {
        [KEYS.URL] = "https://github.com/raysan5/raygui/archive/refs/tags/3.1.zip",
        [KEYS.DIR_I] = "./raygui-3.1/",
    },
    -- A tiny cross-platform webview C library to build modern cross-platform GUIs
    ["webview"] = {
        [KEYS.URL] = "git@github.com:javalikescript/webview-c.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = {"./", "./ms.webview2/include"},
        [KEYS.LIB_L] = {"ole32", "comctl32", "oleaut32", "uuid", "gdi32"},
        [KEYS.FLAGS] = "-DWEBVIEW_WINAPI=1",
    },
    -- A simple logging library implemented in C99
    ["log"] = {
        [KEYS.URL] = "git@github.com:rxi/log.c.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = "./src/",
    },
    -- A Tiny Garbage Collector for C
    ["tgc"] = {
        [KEYS.URL] = "git@github.com:orangeduck/tgc.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = "./",
    },
    -- A tiny ANSI C library for loading .ini config files
    ["ini"] = {
        [KEYS.URL] = "git@github.com:rxi/ini.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = "./src/",
    },
    -- Dynamic memory tracker for C
    ["dmt"] = {
        [KEYS.URL] = "git@github.com:rxi/dmt.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = "./src/",
        [KEYS.FLAGS] = " -Wall",
    },
    -- A tiny C library for generating uuid4 strings
    ["uuid4"] = {
        [KEYS.URL] = "git@github.com:rxi/uuid4.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = "./src/",
    },
    -- tiny file dialogs
    ["tinyfiledialogs"] = {
        [KEYS.URL] = "git@github.com:native-toolkit/tinyfiledialogs.git",
        [KEYS.BRANCH] = "master",
        [KEYS.LIB_L] = {"comdlg32", "ole32"},
        [KEYS.DIR_I] = "./",
    },
    -- (Keep It) Simple Stupid Database
    ["kissdb"] = {
        [KEYS.URL] = "git@github.com:adamierymenko/kissdb.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = "./",
    },
    -- Lightweight JSON library written in C.
    ["parson"] = {
        [KEYS.URL] = "git@github.com:kgabis/parson.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = "./",
    },
    -- single header utf8 string functions for C and C++
    ["utf8"] = {
        [KEYS.URL] = "git@github.com:sheredom/utf8.h.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = "./",
    },
    -- Tiny cross-platform HTTP / HTTPS client library in C.
    ["naett"] = {
        [KEYS.URL] = "git@github.com:erkkah/naett.git",
        [KEYS.BRANCH] = "main",
        [KEYS.DIR_I] = "./",
        [KEYS.LIB_L] = {"winhttp"},
        [KEYS.FLAGS] = " -g -Wall -pedantic ",
    },
    -- C library to encode and decode strings with base64 format
    ["base64"] = {
        [KEYS.URL] = "git@github.com:elzoughby/Base64.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = "./",
    },
    -- Small, portable implementation of the C11 threads API
    ["thread"] = {
        [KEYS.URL] = "git@github.com:tinycthread/tinycthread.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = "./source/",
    },
    -- A tiny embeddable HTTP server written in C89
    ["sandbird"] = {
        [KEYS.URL] = "git@github.com:rxi/sandbird.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = "./src/",
        [KEYS.LIB_L] = {"ws2_32"},
        [KEYS.FLAGS] = " -pedantic -Wall -Wextra ",
        [KEYS.FILES] = {"sandbird.c"},
    },
    -- A lightweight tar library written in ANSI C
    ["microtar"] = {
        [KEYS.URL] = "git@github.com:rxi/microtar.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = "./src/",
        [KEYS.FILES] = {"microtar.c"},
    },
    -- Asynchronous networking for C
    ["dyad"] = {
        [KEYS.URL] = "git@github.com:rxi/dyad.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = "./src/",
        [KEYS.FILES] = {"dyad.c"},
        [KEYS.WIN] = {
            [KEYS.LIB_L] = {"ws2_32"},
        },
    },
    -- A simple, commented reference implementation of the MD5 hash algorithm
    ["md5"] = {
        [KEYS.URL] = "git@github.com:Zunawe/md5-c.git",
        [KEYS.BRANCH] = "main",
        [KEYS.DIR_I] = "./",
        [KEYS.FILES] = {"md5.c"},
    },
    -- stb single-file public domain libraries for C/C++
    ["stb"] = {
        [KEYS.URL] = "git@github.com:nothings/stb.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = "./",
    },
    -- Include binary files in C/C++
    ["incbin"] = {
        [KEYS.URL] = "git@github.com:graphitemaster/incbin.git",
        [KEYS.BRANCH] = "main",
        [KEYS.DIR_I] = "./",
    },
    -- A simple Bitmap (BMP) library.
    ["bmp"] = {
        [KEYS.URL] = "git@github.com:marc-q/libbmp.git",
        [KEYS.BRANCH] = "master",
        [KEYS.DIR_I] = "./",
        [KEYS.FILES] = {"libbmp.c"},
    },
}