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
        local cmd = string.format("git clone %s %s", url, directory)
        local isOk = os.execute(cmd)
        builder_assert(isOk, "git clone failed!")
    elseif GIT_NEED_PULL then
        builder_print('pulling...')
        local cmd = string.format("cd %s && git pull", directory)
        local isOk = os.execute(cmd)
        builder_assert(isOk, "git pull failed!")
    end
    builder_print('complete!')
end

local function builder_download_by_http(config)
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
    builder_print('downloading...')
    http.download(url, cacheFile)
    builder_print('unzipping...')
    local cmd = string.format("unzip %s -d %s", cacheFile, directory)
    local isOk = os.execute(cmd)
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
    if config[KEYS.TYPE] == TYPES.GIT then
        builder_download_by_git(config)
    elseif config[KEYS.TYPE] == TYPES.HTTP then
        builder_download_by_http(config)
    else
        builder_error(string.format('invalid lib type [%s]', config[KEYS.TYPE]))
    end
end

function builder_install_libs(...)
    builder_print('START!')
    builder_prepare_env()
    local libs = {...}
    for i=1,#libs,1 do
        local lib = libs[i]
        builder_print(string.format('install:%s -> start:', lib))
        builder_install_lib(lib)
        builder_print(string.format('install:%s -> end!', lib))
    end
    builder_print('END!')
end

builder_install_libs("minilua", "minicoro", "tigr", "raylib")

