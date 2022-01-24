--[[
    configs
]]

LIBRARIES = {
    MINILUA = "minilua",
    MINICORO = "minicoro",
    TIGR = "tigr",
    RAYLIB = "raylib",
}

CONFIGS = {
    [LIBRARIES.MINILUA] = {
        [KEYS.NAME] = LIBRARIES.MINILUA,
        [KEYS.TYPE] = TYPES.GIT,
        [KEYS.URL] = "https://github.com/edubart/minilua.git",
        [KEYS.BRANCH] = "main",
    },
    [LIBRARIES.MINICORO] = {
        [KEYS.NAME] = LIBRARIES.MINICORO,
        [KEYS.TYPE] = TYPES.GIT,
        [KEYS.URL] = "https://github.com/edubart/minicoro.git",
        [KEYS.BRANCH] = "main",
    },
    [LIBRARIES.TIGR] = {
        [KEYS.NAME] = LIBRARIES.TIGR,
        [KEYS.TYPE] = TYPES.GIT,
        [KEYS.URL] = "https://github.com/erkkah/tigr.git",
        [KEYS.BRANCH] = "master",
    },
    [LIBRARIES.RAYLIB] = {
        [KEYS.NAME] = LIBRARIES.RAYLIB,
        [KEYS.TYPE] = TYPES.HTTP,
        [KEYS.URL] = "https://github.com/raysan5/raylib/releases/download/4.0.0/raylib-4.0.0_win64_mingw-w64.zip",
    },
}