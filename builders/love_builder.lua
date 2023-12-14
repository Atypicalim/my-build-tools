--[[
    lua
]]

MyLoveBuilder, MyLoveSuper = class("MyLoveBuilder", MyBuilderBase)

function MyLoveBuilder:__init__()
    MyLoveSuper.__init__(self, "lua")
    self._targetName = "target"
    self._targetExecutable = nil
end

function MyLoveBuilder:setOutput(path)
    MyCSuper.setOutput(self, path)
    self._targetExecutable = tools.is_windows() and string.format( "%s.exe", tostring(self._outputFile)) or tostring(self._outputFile)
    return self
end

function MyLoveBuilder:_processBuild()
    self:_print('PROCESS PACKAGE START!')
    self:_assert(self._inputFiles[1] ~= nil, "input files are not defined!")
    self:_assert(self._outputFile ~= nil, "output file is not defined!")
    --
    local love = self._rootDir .. "tools/love-11.5-win64/love.exe"
    local dll = self._rootDir .. "tools/love-11.5-win64/love.dll"
    files.copy(love, self._projDir .. "love.exe")
    files.copy(dll, self._projDir .. "love.dll")
    local input = self._inputFiles[1]
    -- zipping folder
    self:_print("zipping...")
    local zipCmd = string.format("zip -9 -r -j %s.love %s", self._targetName, self._projDir)
    if self._isDebug then
        self:_print(string.format("cmd:%s", zipCmd))
    end
    local isOk, output = tools.execute(zipCmd)
    if not isOk then
        self:_print("package process failed!")
        self:_error("err:" .. output)
    end
    -- copying binaries
    self:_print("copying...")
    local copyCmd = string.format("cmd /c copy /b love.exe+%s.love %s.exe", self._targetName, self._targetName)
    if self._isDebug then
        self:_print(string.format("cmd:%s", copyCmd))
    end
    local isOk, output = tools.execute(copyCmd)
    if not isOk then
        self:_print("package process failed!")
        self:_error("err:" .. output)
    end
    --
    self:_print('PROCESS PACKAGE END!')
    return self
end

function MyLoveBuilder:run(path)
    path = path and (self._projDir .. path) or self._targetExecutable
    self:_print("RUNNING:" .. path)
    os.execute(path)
end
