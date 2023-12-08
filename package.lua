--[[
    packaging build tool
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

