--[[
    html
]]

local Base = require("builder_base")
local Builder, Super = class("Builder", Base)

function Builder:__init__()
    Super.__init__(self, "html")
    self._lineArr = {}
    self._fileMap = {}
    self:_prepareEnv()
end

function Builder:_prepareEnv()
    Super._prepareEnv(self)
end

function Builder:inputFile(path)
    self:assert(self._inputFile == nil, "input can only be one file")
    self._inputFile = path
end

function Builder:containScript(isOnlyLocal)
    self._isContainScript = true
    self._isScriptLocal = isOnlyLocal == true
end

function Builder:containStyle(isOnlyLocal)
    self._isContainStyle = true
    self._isStyleLocal = isOnlyLocal == true
end

function Builder:containImage(isOnlyLocal)
    self._isContainImage = true
    self._isImageLocal = isOnlyLocal == true
end

function Builder:outputFile(path)
    self:assert(self._outputFile == nil, "output can only be one file")
    self._outputFile = path
end

local SCRIPT_TEMPLATE = [[
<script type="text/javascript" origin_file="%s">
%s
</script>
]]

function Builder:_processScript(line, path)
    if not self._isContainScript then return end
    self:print("process script:", path)
    local content = self:_readFile(path, self._isScriptLocal)
    return string.format(SCRIPT_TEMPLATE, path, content)
end

local STYLE_TEMPLATE = [[
<style type="text/css" file="%s">
%s
</style>
]]

function Builder:_processStyle(line, path)
    if not self._isContainStyle then return end
    self:print("process style:", path)
    local content = self:_readFile(path, self._isScriptLocal)
    return string.format(STYLE_TEMPLATE, path, content)
end

function Builder:_processImage(line, path)
    if not self._isContainImage then return end
    self:print("process image:", path)
    local content = self:_readFile(path, self._isScriptLocal, true)
    local base64 = encryption.base64_encode(content)
    local data = string.format("data:image/png;base64,%s", base64)
    return string.gsub(line, string.escape(path), data)
end

function Builder:start()
    --
    self:print("start:")
    self:print("contain script:", self._isContainScript == true)
    self:print("contain style:", self._isContainStyle == true)
    self:print("contain image:", self._isContainImage == true)
    self:assert(self._inputFile ~= nil, "input path not found")
    local content = files.read(self._inputFile)
    self:assert(#content > 0, "input file is empty")
    self._lineArr = string.explode(content, "\n")
    --
    local urlRule = "[\'\"]([^\n\'\"]*)[\'\"]"
    for i,line in ipairs(self._lineArr) do
        local newLine = nil
        if not newLine then
            local scriptPath = string.match(string.lower(line), "<script[^\n]*src=" .. urlRule)
            if scriptPath then
                newLine = self:_processScript(line, scriptPath)
            end
        end
        if not newLine then
            local stylePath = string.match(string.lower(line), "<link[^\n]*href=" .. urlRule)
            if stylePath then
                newLine = self:_processStyle(line, stylePath)
            end
        end
        if not newLine then
            local imagePath = string.match(string.lower(line), "<img[^\n]*src=" .. urlRule)
            if imagePath then
                newLine = self:_processImage(line, imagePath)
            end
        end
        if newLine then
            self._lineArr[i] = newLine
        end
    end
    self:print("contain end.")
    --
    self:print("creating target ...")
    local html = table.concat(self._lineArr, "\n")
    self:assert(self._outputFile ~= nil, "output path not found")
    files.write(self._outputFile, html)
    self:print("writing target succeeded!")
    self:print("finish!\n")
end

return Builder
