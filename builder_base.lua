--[[
    base
]]

-- download lua tools
local function download_and_import_by_git(gitUrl, entryName, workingDir)
    local slashPos = string.find(string.reverse(gitUrl), "/", 1, true)
    local pointPos = string.find(string.reverse(gitUrl), ".", 1, true)
    assert(slashPos ~= nil and pointPos ~= nil and slashPos > pointPos, "[LUA_GIT_IMPORT] invalid url:" .. gitUrl)
    local folderName = string.sub(gitUrl, #gitUrl - slashPos + 2, #gitUrl - pointPos) .. "/"
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

local path = debug.getinfo(1).short_src
path = string.gsub(path, '\\', "/")
path = string.gsub(path, "[^\\/]+%.[^\\/]+", "")
download_and_import_by_git("git@github.com:kompasim/pure-lua-tools.git", "test", path)

local Builder = class("Builder")

function Builder:__init__(buildType)
    buildType = string.lower(buildType)
    self._printTag = "[build_" .. buildType .. "_tool]"
    local dir = nil
    local idx = 1
    while true do
        local d = files.csd(idx)
        idx = idx + 1
        if not d then break end
        if (files.is_folder(d)) then
            dir = d
        end
    end
    self._projDir = dir
    self._workDir = files.csd() .. "/build/"
    self._buildDir = self._workDir .. buildType .. "_dir/"
    self._cacheDir = self._workDir .. "cache/"
    self._needUpdate = false
    self._inputNames = {}
    self._inputFiles = {}
    self._outputFile = nil
    files.mk_folder(self._buildDir)
    print('\n-----------------[Lua ' .. buildType .. ' Builder]---------------------\n')
end

function Builder:_print(...)
    print(self._printTag, ...)
end

function Builder:_assert(v, msg)
    assert(v, string.format("%s %s", self._printTag, msg))
end

function Builder:_error(msg)
    error(string.format("%s %s", self._printTag, msg))
end

function Builder:_downloadByGit(url, branch, directory)
    if not files.is_folder(directory) then
        self:_print('cloning...')
        local cmd = string.format("git clone %s %s --branch %s --single-branch", url, directory, branch)
        local isOk, err = tools.execute(cmd)
        self:_assert(isOk, "git clone failed, err:" .. tostring(err))
    elseif self._needUpdate then
        self:_print('pulling...')
        local cmd = string.format("cd %s && git pull", directory)
        local isOk, err = tools.execute(cmd)
        self:_assert(isOk, "git pull failed:" .. tostring(err))
    end
end

function Builder:_downloadByZip(url, directory)
    if files.is_folder(directory) then
        self:_print('downloaded!')
        return
    end
    local cacheFile = self:_downloadByUrl(url)
    self:_print('unzipping...')
    local cmd = string.format("unzip %s -d %s", cacheFile, directory)
    local isOk, err = tools.execute(cmd)
    files.delete(cacheFile)
    self:_assert(isOk, "unzip failed, err:" .. tostring(err))
end

function Builder:_downloadByGzip(url, directory)
    if files.is_folder(directory) then
        self:_print('downloaded!')
        return
    end
    local cacheFile = self:_downloadByUrl(url)
    self:_print('gunzipping...')
    files.mk_folder(directory)
    local cmd = string.format("tar xzvf %s -C %s", cacheFile, directory)
    local isOk, err = tools.execute(cmd)
    files.delete(cacheFile)
    self:_assert(isOk, "gunzip failed, err:" .. tostring(err))
end

function Builder:_downloadByUrl(url, path)
    local parts = string.explode(url, "%.")
    local ext = parts[#parts]
    local cacheFile = path or self._cacheDir .. "temp." .. ext
    files.delete(cacheFile)
    self:_print('downloading ...')
    local isOk, err = http.download(url, cacheFile, 'curl')
    if not isOk or files.size(cacheFile) == 0 then
        files.delete(cacheFile)
        self:_error('download failed, err:' .. tostring(err))
    end
    self:_print('download succeeded.')
    return cacheFile
end

function Builder:_readFile(path, isOnlyLocal, isBuffer)
    self:_print("read file:" .. path)
    local isRemote = string.find(path, "http") == 1
    self:_print("is remote:" .. tostring(isRemote))
    if isRemote then
        if isOnlyLocal then
            self:_print("skip remote.")
            return
        end
        self:_print("downloading remote ...")
        path = Super._downloadByUrl(self, path)
    end
    self:_assert(files.is_file(path), "file not found:" .. path)
    self:_print("reading file ...")
    local content = files.read(path, isBuffer and "rb" or "r")
    if isRemote then
        files.delete(path)
    end
    self:_assert(#content > 0, "read file failed!, path:" .. path)
    self:_print("read file succeeded!")
    return content
end

function Builder:setInput(...)
    self:_print("input files ...")
    self:_assert(table.is_empty(self._inputFiles), "input files are already defined")
    local fileArr = {...}
    for i,v in ipairs(fileArr) do
        local path = v
        if not files.is_file(path) then
            path = self._projDir .. v
        end
        self:_assert(files.is_file(path), "input file not found:" .. v)
        self:_print("input file:" .. v)
        table.insert(self._inputNames, v)
        table.insert(self._inputFiles, path)
    end
    return self
end

function Builder:setOutput(path)
    self:_print("output file ...")
    self:_assert(self._outputFile == nil, "output file is already defined")
    self:_print("output file:" .. path)
    self._outputFile = self._projDir .. path
    return self
end

function Builder:start()
    self:_error("please implement start func ...")
end

return Builder
