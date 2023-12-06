--[[
    c
]]

local Base = require("builder_base")

-- add resources such as icon and version info
local MY_RC_FILE_TEMPLATE = [[
id ICON "%s"
]]

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
}

local Builder, Super = class("CBuilder", Base)

function Builder:__init__(isDebug)
    Super.__init__(self, "C")
    self._isDebug = isDebug == true
    self._includeDirs = {}
    self._linkingDirs = {}
    self._linkingTags = {}
    self._extraFlags = {}
    self._targetExecutable = nil
    self._libPath = self._workDir .. "libs/"
    files.mk_folder(self._libPath)
    self.MY_RES_FILE_PATH = self._buildDir .. ".lcb_resource.res"
    self.MY_RC_FILE_PATH = self._buildDir .. ".lcb_resource.rc"
    files.write(self.MY_RES_FILE_PATH, "")
    files.write(self.MY_RC_FILE_PATH, "")
end

function Builder:_downloadByGit(config)
    local url = config[KEYS.URL]
    local branch = config[KEYS.BRANCH] or 'master'
    local directory = self._libPath .. config[KEYS.NAME] .. "/"
    Super._downloadByGit(self, url, branch, directory)
end

function Builder:_downloadByZip(config)
    local name = config[KEYS.NAME]
    local url = config[KEYS.URL]
    local directory = self._libPath .. name .. "/"
    Super._downloadByZip(self, url, directory)
end

function Builder:_downloadByGzip(config)
    local name = config[KEYS.NAME]
    local url = config[KEYS.URL]
    local directory = self._libPath .. name .. "/"
    Super._downloadByGzip(self, url, directory)
end

function Builder:_getConfig(name)
    local config = CONFIGS[name]
    self:_assert(config ~= nil, string.format("lib [%s] not found", name))
    if tools.is_windows() then
        table.merge(config, config[KEYS.WIN] or {})
    elseif tools.is_mac() then
        table.merge(config, config[KEYS.MAC] or {})
    elseif tools.is_linux() then
        table.merge(config, config[KEYS.LNX] or {})
    end
    return config
end

function Builder:_installLib(name)
    local config = self:_getConfig(name)
    self:_assert(config ~= nil, string.format("lib [%s] not found", name))
    local parts = string.explode(config[KEYS.URL], "%.")
    config[KEYS.EXT] = string.upper(parts[#parts])
    config[KEYS.TYPE] = config[KEYS.EXT]
    config[KEYS.NAME] = name
    if config[KEYS.TYPE] == TYPES.GIT then
        self:_downloadByGit(config)
    elseif config[KEYS.TYPE] == TYPES.ZIP then
        self:_downloadByZip(config)
    elseif config[KEYS.TYPE] == TYPES.GZ then
        self:_downloadByGzip(config)
    else
        self:_error(string.format('invalid lib type [%s]', config[KEYS.TYPE]))
    end
end

function Builder:_containLib(name)
    local config = self:_getConfig(name)
    local directory = self._libPath .. name .. "/"
    self:_assert(config ~= nil, string.format("lib [%s] not found", name))
    self:_assert(files.is_folder(directory), string.format("lib [%s] not installed", name))
    --
    local function insertInclue(dir)
        dir = directory .. dir
        self:_assert(files.is_folder(dir), string.format("include directory [%s] not found", dir))
        table.insert(self._includeDirs, dir)
    end
    if is_string(config[KEYS.DIR_I]) then
        insertInclue(config[KEYS.DIR_I])
    elseif is_table(config[KEYS.DIR_I]) then
        for _,v in ipairs(config[KEYS.DIR_I]) do
            insertInclue(v)
        end
    end
    --
    local function insertLinking(dir)
        dir = directory .. dir
        self:_assert(files.is_folder(dir), string.format("linking directory [%s] not found", dir))
        table.insert(self._linkingDirs, dir)
    end
    if is_string(config[KEYS.DIR_L]) then
        insertLinking(config[KEYS.DIR_L])
    elseif is_table(config[KEYS.DIR_L]) then
        for _,v in ipairs(config[KEYS.DIR_L]) do
            insertLinking(v)
        end
    end
    --
    local function insertTags(tag)
        table.insert(self._linkingTags, tag)
    end
    if is_string(config[KEYS.LIB_L]) then
        insertTags(config[KEYS.LIB_L])
    elseif is_table(config[KEYS.LIB_L]) then
        for _,v in ipairs(config[KEYS.LIB_L]) do
            insertTags(v)
        end
    end
    --
    if is_string(config[KEYS.FLAGS]) then
        table.insert(self._extraFlags, config[KEYS.FLAGS])
    end
end

function Builder:_containFiles(name)
    local config = self:_getConfig(name)
    self:_assert(config ~= nil, string.format("lib [%s] not found", name))
    local directory = self._libPath .. name .. "/"
    local arr = config[KEYS.FILES] or {}
    for i,v in ipairs(arr) do
        local path = v
        if not files.is_file(path) then
            path = directory .. config[KEYS.DIR_I] .. v
        end
        self:_assert(files.is_file(path), "input file not found:" .. v)
        table.insert(self._inputNames, v)
        table.insert(self._inputFiles, path)
    end
end

function Builder:setLibs(...)
    self:_print('CONTAIN LIB START!')
    local libs = {...}
    if is_table(libs[1]) then
        libs = libs[1]
    end
    for i=1,#libs,1 do
        local lib = libs[i]
        self:_print(string.format("contain:[%s]", lib))
        self:_installLib(lib)
        self:_containLib(lib)
        self:_containFiles(lib)
    end
    self:_print('CONTAIN LIB END!')
    return self
end

function Builder:setIcon(iconPath)
    self:_print('SET ICON START!')
    self:_print('icon:', iconPath)
    if not tools.is_windows() then
        self:_print('SET ICON IGNORED!')
        return
    end
    iconPath = self._projDir .. iconPath
    local myRcInfo = string.format(MY_RC_FILE_TEMPLATE, iconPath)
    files.write(self.MY_RC_FILE_PATH, myRcInfo)
    local isOk, err = tools.execute(string.format("windres %s -O coff -o %s", self.MY_RC_FILE_PATH, self.MY_RES_FILE_PATH))
    self:_assert(isOk, "resource compile failed, err:" .. tostring(err))
    self:_print('SET ICON END!')
    return self
end

function Builder:setOutput(path)
    Super.setOutput(self, path)
    self._targetExecutable = tools.is_windows() and string.format( "%s.exe", tostring(self._outputFile)) or tostring(self._outputFile)
    return self
end

function Builder:start(isRelease)
    self:_print('PROCESS GCC START!')
    self:_assert(self._inputFiles[1] ~= nil, "input files are not defined!")
    self:_assert(self._outputFile ~= nil, "output file is not defined!")
    --
    local includeDirCmd = ""
    for _,v in ipairs(self._includeDirs) do
        includeDirCmd = includeDirCmd .. " -I " .. v
    end
    --
    local linkingDirCmd = ""
    for _,v in ipairs(self._linkingDirs) do
        linkingDirCmd = linkingDirCmd .. " -L " .. v
    end
    --
    local linkingTagCmd = ""
    for _,v in ipairs(self._linkingTags) do
        linkingTagCmd = linkingTagCmd .. " -l " .. v
    end
    --
    local extraFlagsCmd = ""
    for _,v in ipairs(self._extraFlags) do
        extraFlagsCmd = extraFlagsCmd .. " " .. v
    end
    --
    local resCmds = tools.is_windows() and string.format("%s", self.MY_RES_FILE_PATH) or ""
    --
    local icludeCmds = string.format("%s", includeDirCmd)
    local linkCmds = string.format("%s %s", linkingDirCmd, linkingTagCmd)
    local inputFiles = ""
    for i,v in ipairs(self._inputFiles) do
        inputFiles = inputFiles .. " " .. v
    end
    local cc = tools.is_windows() and "gcc" or "clang"
    local cmd = string.format("%s %s -o %s %s %s %s %s", cc, inputFiles, self._targetExecutable, resCmds, icludeCmds, linkCmds, extraFlagsCmd)
    --
    if isRelease then
        cmd = cmd .. " -O2 -mwindows"
    end
    --
    if self._isDebug then
        self:_print(string.format("cmd:%s", cmd))
    end
    local isOk, output = tools.execute(cmd)
    if not isOk then
        self:_print("gcc process failed!")
        self:_error("err:" .. output)
    end
    self:_print("gcc process succeeded!")
    --
    files.delete(self.MY_RES_FILE_PATH)
    files.delete(self.MY_RC_FILE_PATH)
    self:_print('PROCESS GCC END!\n')
    return self
end

function Builder:run(path)
    path = path and (self._projDir .. path) or self._targetExecutable
    self:_print("RUNNING:" .. path)
    os.execute(path)
end

return Builder
