--[[
    html
]]

MyHtmlBuilder, MyHtmlSuper = class("MyHtmlBuilder", MyBuilderBase)

function MyHtmlBuilder:__init__()
    MyHtmlSuper.__init__(self, "html")
    self._lineArr = {}
    self._fileMap = {}
end

function MyHtmlBuilder:containScript(isOnlyLocal)
    self._isContainScript = true
    self._isScriptLocal = isOnlyLocal == true
    return self
end

function MyHtmlBuilder:containStyle(isOnlyLocal)
    self._isContainStyle = true
    self._isStyleLocal = isOnlyLocal == true
    return self
end

function MyHtmlBuilder:containImage(isOnlyLocal)
    self._isContainImage = true
    self._isImageLocal = isOnlyLocal == true
    return self
end

local HTML_SCRIPT_TEMPLATE = [[
<script type="text/javascript" origin_file="%s">
%s
</script>
]]

function MyHtmlBuilder:_processScript(line, path)
    if not self._isContainScript then return end
    self:_print("process script:", path)
    local content = self:_readFile(path, self._isScriptLocal)
    return string.format(HTML_SCRIPT_TEMPLATE, path, content)
end

local HTML_STYLE_TEMPLATE = [[
<style type="text/css" file="%s">
%s
</style>
]]

function MyHtmlBuilder:_processStyle(line, path)
    if not self._isContainStyle then return end
    self:_print("process style:", path)
    local content = self:_readFile(path, self._isScriptLocal)
    return string.format(HTML_STYLE_TEMPLATE, path, content)
end

function MyHtmlBuilder:_processImage(line, path)
    if not self._isContainImage then return end
    self:_print("process image:", path)
    local content = self:_readFile(path, self._isScriptLocal, true)
    local base64 = encryption.base64_encode(content)
    local data = string.format("data:image/png;base64,%s", base64)
    return string.gsub(line, string.escape(path), data)
end

function MyHtmlBuilder:_processBuild()
    --
    self:_print("contain script:", self._isContainScript == true)
    self:_print("contain style:", self._isContainStyle == true)
    self:_print("contain image:", self._isContainImage == true)
    self:_assert(#self._inputFiles >= 1, "input file not found")
    self:_assert(#self._inputFiles <= 1, "input file too much")
    local content = files.read(self._inputFiles[1])
    self:_assert(#content > 0, "input file is empty")
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
    self:_print("contain end.")
    --
    self:_print("creating target ...")
    local html = table.concat(self._lineArr, "\n")
    self:_assert(self._outputFile ~= nil, "output path not found")
    files.write(self._outputFile, html)
    self:_print("writing target succeeded!")
    return self
end
