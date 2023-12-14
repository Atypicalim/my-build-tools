--[[
    lua
]]

MyLuaBuilder, MyLuaSuper = class("MyLuaBuilder", MyBuilderBase)

function MyLuaBuilder:__init__()
    MyLuaSuper.__init__(self, "lua")
    self._targetExecutable = nil
end

function MyLuaBuilder:setOutput(path)
    MyCSuper.setOutput(self, path)
    self._targetExecutable = tools.is_windows() and string.format( "%s.exe", tostring(self._outputFile)) or tostring(self._outputFile)
    return self
end

function MyLuaBuilder:_processBuild()
    self:_print('PROCESS PACKAGE START!')
    self:_assert(self._inputFiles[1] ~= nil, "input files are not defined!")
    self:_assert(self._outputFile ~= nil, "output file is not defined!")
    -- https://web.archive.org/web/20130721014948if_/http://www.soongsoft.com/lhf/lua/5.1/srlua.tgz
    local glue = self._rootDir .. "tools/srlua/glue.exe"
    local srlua = self._rootDir .. "tools/srlua/srlua.exe"
    local inputs = ""
    for i,v in ipairs(self._inputFiles) do
        inputs = inputs .. v .. " "
    end
    -- glue srlua.exe source.lua target.exe
    local cmd = string.format("%s %s %s %s.exe", glue, srlua, inputs, self._outputFile)
    if self._isRelease then
        cmd = cmd
    end
    if self._isDebug then
        self:_print(string.format("cmd:%s", cmd))
    end
    -- 
    self:_print('packaging...')
    local isOk, output = tools.execute(cmd)
    if not isOk then
        self:_print("package process failed!")
        self:_error("err:" .. output)
    end
    --
    self:_print('PROCESS PACKAGE END!')
    return self
end

function MyLuaBuilder:run(path)
    path = path and (self._projDir .. path) or self._targetExecutable
    self:_print("RUNNING:" .. path)
    os.execute(path)
end
