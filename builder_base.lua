--[[
    base
]]

-- download lua tools
local function download_and_import_by_git(gitUrl, entryName, workingDir)
    local slashPos = string.find(string.reverse(gitUrl), "/", 1, true)
    local pointPos = string.find(string.reverse(gitUrl), ".", 1, true)
    assert(slashPos ~= nil and pointPos ~= nil and slashPos > pointPos, "[LUA_GIT_IMPORT] invalid url:" .. gitUrl)
    local folderName = "." .. string.sub(gitUrl, #gitUrl - slashPos + 2, #gitUrl - pointPos) .. "/"
    workingDir = workingDir or os.getenv("HOME")
    assert(workingDir ~= nil, "[LUA_GIT_IMPORT] working dir not found !")
    package.path = package.path .. ";" .. workingDir .. "/" .. folderName .. "?.lua"
    local isOk, err = pcall(require, entryName)
    if not isOk then
        print('[LUA_GIT_IMPORT] downloading ...')
        os.execute("git clone " .. gitUrl .. " " .. workingDir .. "/" .. folderName)
        isOk, err = pcall(require, entryName)
        assert(isOk, "[LUA_GIT_IMPORT] import failed:" .. tostring(err))
        print('[LUA_GIT_IMPORT] import succeeded!')
    end
end

download_and_import_by_git("git@github.com:kompasim/pure-lua-tools.git", "initialize", "./")

local Builder = class("Builder")

function Builder:__init__(buildType)
    buildType = string.lower(buildType)
    self._printTag = "[build_" .. buildType .. "_tool]"
    self._mainDir = "./.build/"
    self._buildDir = self._mainDir .. buildType .. "_dir/"
    self._cacheDir = self._mainDir .. "cache/"
    self._needUpdate = false
    print('\n-----------------[Lua ' .. buildType .. ' Builder]---------------------\n')
end

function Builder:_prepareEnv()
    if not class then
        self:error('pure lua tools not found!')
    end
    if not files.is_folder(self._buildDir) then
        files.mk_folder(self._buildDir)
    end
end

function Builder:print(...)
    print(self._printTag, ...)
end

function Builder:assert(v, msg)
    assert(v, string.format("%s%s", self._printTag, msg))
end

function Builder:error(msg)
    error(string.format("%s%s", self._printTag, msg))
end

function Builder:_downloadByGit(url, branch, directory)
    if not files.is_folder(directory) then
        self:print('cloning...')
        local cmd = string.format("git clone %s %s --branch %s --single-branch", url, directory, branch)
        local isOk, err = tools.execute(cmd)
        self:assert(isOk, "git clone failed, err:" .. tostring(err))
    elseif self._needUpdate then
        self:print('pulling...')
        local cmd = string.format("cd %s && git pull", directory)
        local isOk, err = tools.execute(cmd)
        self:assert(isOk, "git pull failed:" .. tostring(err))
    end
end

function Builder:_downloadByZip(url, directory)
    if files.is_folder(directory) then
        self:print('downloaded!')
        return
    end
    local cacheFile = self:_downloadByUrl(url)
    self:print('unzipping...')
    local cmd = string.format("unzip %s -d %s", cacheFile, directory)
    local isOk, err = tools.execute(cmd)
    files.delete(cacheFile)
    self:assert(isOk, "unzip failed, err:" .. tostring(err))
end

function Builder:_downloadByUrl(url, path)
    local parts = string.explode(url, "%.")
    local ext = parts[#parts]
    local cacheFile = path or self._cacheDir .. "temp." .. ext
    files.delete(cacheFile)
    self:print('downloading ...')
    local isOk, err = http.download(url, cacheFile, 'curl')
    if not isOk or files.size(cacheFile) == 0 then
        files.delete(cacheFile)
        self:error('download failed, err:' .. tostring(err))
    end
    self:print('download succeeded.')
    return cacheFile
end

return Builder
