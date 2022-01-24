--[[
    builder
]]

require("pure-lua-tools.initialize")
require("constants")
require("configs")

local function builder_print(...)
    print(MY_PRINT_TAG, ...)
end

local function builder_assert(v, msg)
    assert(v, string.format("%s%s", MY_PRINT_TAG, msg))
end

local function builder_error(msg)
    error(string.format("%s%s", MY_PRINT_TAG, msg))
end

local function builder_download_by_git(config)
    local name = config[KEYS.NAME]
    local url = config[KEYS.URL]
    local branch = config[KEYS.BRANCH] or 'master'
    local directory = MY_LIBRARY_PATH .. name .. "/"
    if not files.is_folder(directory) then
        builder_print('cloning...')
        local cmd = string.format("git clone %s %s --branch %s --single-branch", url, directory, branch)
        local isOk = tools.execute(cmd)
        builder_assert(isOk, "git clone failed!")
    elseif GIT_NEED_PULL then
        builder_print('pulling...')
        local cmd = string.format("cd %s && git pull", directory)
        local isOk = tools.execute(cmd)
        builder_assert(isOk, "git pull failed!")
    end
    builder_print('complete!')
end

local function builder_download_by_zip(config)
    local name = config[KEYS.NAME]
    local url = config[KEYS.URL]
    local parts = string.explode(url, "%.")
    local ext = parts[#parts]
    local directory = MY_LIBRARY_PATH .. name .. "/"
    local cacheDir = MY_LIBRARY_PATH .. ".temp/"
    local cacheFile = cacheDir .. name .. "." .. ext
    if files.is_folder(directory) then
        builder_print('downloaded!')
        return
    end
    local isOk, err
    if not isOk then
        builder_print('downloading with pws1 ...')
        isOk, err = http.download(url, cacheFile, 'pws1')
    end
    if not isOk then
        builder_print('download failed with pws1, err:' .. err)
        builder_print('downloading with curl ...')
        isOk, err = http.download(url, cacheFile, 'curl')
    end
    if not isOk then
        builder_print('download failed with curl, err:' .. err)
        builder_print('downloading with wget ...')
        isOk, err = http.download(url, cacheFile, 'wget')
    end
    if not isOk then
        builder_error('download failed with wget, err:' .. err)
    end
    builder_print('unzipping...')
    local cmd = string.format("unzip %s -d %s", cacheFile, directory)
    local isOk = tools.execute(cmd)
    builder_assert(isOk, "unzip failed!")
    builder_print('complete!')
end

local function builder_prepare_env()
    if not files or not files.mk_folder then
        builder_error('pure lua tools not found!')
    end
    if not files.is_folder(MY_LIBRARY_PATH) then
        files.mk_folder(MY_LIBRARY_PATH)
    end
end

local function builder_install_lib(name)
    local config = CONFIGS[name]
    builder_assert(config ~= nil, string.format("lib [%s] not found", name))
    local parts = string.explode(config[KEYS.URL], "%.")
    config[KEYS.EXT] = string.upper(parts[#parts])
    config[KEYS.TYPE] = config[KEYS.EXT]
    config[KEYS.NAME] = name
    if config[KEYS.TYPE] == TYPES.GIT then
        builder_download_by_git(config)
    elseif config[KEYS.TYPE] == TYPES.ZIP then
        builder_download_by_zip(config)
    else
        builder_error(string.format('invalid lib type [%s]', config[KEYS.TYPE]))
    end
end

function builder_install_libs(...)
    builder_print('INSTALL LIB START!')
    builder_prepare_env()
    local libs = {...}
    for i=1,#libs,1 do
        local lib = libs[i]
        builder_print(string.format('install:%s -> start:', lib))
        builder_install_lib(lib)
        builder_print(string.format('install:%s -> end.', lib))
    end
    builder_print('INSTALL LIB END!\n')
end

local includeDirs = {}
local linkingDirs = {}
local linkingTags = {}
local executableFile = nil

local function builder_include_lib(name)
    local config = CONFIGS[name]
    local directory = MY_LIBRARY_PATH .. name .. "/"
    builder_assert(config ~= nil, string.format("lib [%s] not found", name))
    builder_assert(files.is_folder(directory), string.format("lib [%s] not installed", name))
    --
    local function insertInclue(dir)
        dir = directory .. dir
        builder_assert(files.is_folder(dir), string.format("include directory [%s] not found", dir))
        table.insert(includeDirs, dir)
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
        builder_assert(files.is_folder(dir), string.format("linking directory [%s] not found", dir))
        table.insert(linkingDirs, dir)
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
        table.insert(linkingTags, tag)
    end
    if is_string(config[KEYS.LIB_L]) then
        insertTags(config[KEYS.LIB_L])
    elseif is_table(config[KEYS.LIB_L]) then
        for _,v in ipairs(config[KEYS.LIB_L]) do
            insertTags(v)
        end
    end
end

function builder_contain_libs(...)
    builder_print('CONTAIN LIB START!')
    local libs = {...}
    for i=1,#libs,1 do
        local lib = libs[i]
        builder_include_lib(lib)
    end
    builder_print('CONTAIN LIB END!\n')
end

function builder_process_gcc(codePath, isRelease)
    builder_print('PROCESS GCC START!')
    --
    local includeDirCmd = ""
    for _,v in ipairs(includeDirs) do
        includeDirCmd = includeDirCmd .. " -I " .. v
    end
    --
    local linkingDirCmd = ""
    for _,v in ipairs(linkingDirs) do
        linkingDirCmd = linkingDirCmd .. " -L " .. v
    end
    --
    local linkingTagCmd = ""
    for _,v in ipairs(linkingTags) do
        linkingTagCmd = linkingTagCmd .. " -l " .. v
    end
    --
    local parts = string.explode(codePath, "%.")
    local name = string.lower(parts[#parts - 1])
    local target = string.format( "%s.exe", name)
    local cmd = string.format("gcc %s -o %s %s %s %s", codePath, target, includeDirCmd, linkingDirCmd, linkingTagCmd)
    if files.is_file(target) then
        executableFile = target
    end
    --
    if isRelease then
        cmd = cmd .. " -O2 -mwindows"
    end
    --
    local isOk, output = tools.execute(cmd)
    if not isOk then
        builder_print("gcc process failed, cmd:" .. cmd)
        builder_error("err:" + output)
    end
    builder_print("gcc process succeeded!")
    --
    builder_print('PROCESS GCC END!\n')
end

function builder_program_run(argumentString)
    builder_assert(executableFile ~= nil, 'executable file not found!')
    argumentString = argumentString or ""
    tools.execute(executableFile .. argumentString)
end

builder_install_libs("minilua", "minicoro", "tigr", "raylib", "webview")
builder_contain_libs("raylib")
builder_process_gcc("test.c", true)
builder_program_run()

