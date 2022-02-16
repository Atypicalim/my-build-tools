--[[
    code
]]

local Base = require("builder_base")
local Builder, Super = class("Builder", Base)

function Builder:__init__()
    Super.__init__(self, "c")
    self._lineArr = {}
    self._macroStartTag = "[M["
    self._macroEndTag = "]M]"
end

function Builder:printHeader(headerTag, height)
    self:print("print header ...")
    self:assert(self._isPrintHeader == nil, "print header is already defined")
    self:assert(is_string(headerTag), "header tag should be string")
    self._isPrintHeader = true
    self._headerTag = headerTag
    self._headerHeight = height
    self:print("header tag:" .. tostring(self._headerTag))
end

function Builder:handleMacro(...)
    self:print("handle macro ...")
    self:assert(self._isHandleMacro == nil, "handle macro is already defined")
    self._isHandleMacro = true
    self:assert(self._commentTags == nil, "comment tag is already defined")
    self._commentTags = {...}
    self:assert(not table.is_empty(self._commentTags), "comment tag should be string")
    self:print("comment tags:" .. table.implode(self._commentTags, ","))
end

function Builder:_COMMAND_FILE_BASE64(code, arguments)
    local filePath = arguments[1]
    self:assert(files.is_file(filePath), "file not found, path:" .. filePath)
    local content = files.read(filePath)
    local data = encryption.base64_encode(content)
    return string.format(code, data)
end

function Builder:_COMMAND_FILE_PLAIN(code, arguments)
    local filePath = arguments[1]
    self:assert(files.is_file(filePath), "file not found, path:" .. filePath)
    local content = files.read(filePath)
    return string.format(code, content)
end

function Builder:_COMMAND_FILE_STRING(code, arguments)
    local filePath = arguments[1]
    local minimize = arguments[2] ~= nil and string.lower(arguments[2]) == "true"
    self:assert(files.is_file(filePath), "file not found, path:" .. filePath)
    local fileContent = files.read(filePath)
    local lineArr = string.explode(fileContent, "\n")
    for i,v in ipairs(lineArr) do
        lineArr[i] = v:gsub("[\n\r]+$", " "):gsub("\"", "\\\""):gsub("\'", "\\\'")
    end
    local result = table.implode(lineArr, " \\n ")
    if minimize then
        result = result:gsub("%s+", " ")
    end
    return string.format(code, result)
end


function Builder:_parseLine(line)
    if not self._isHandleMacro then
        return
    end
    local commentPosition = nil
    for i,v in ipairs(self._commentTags or {}) do
        if not commentPosition then
            commentPosition = string.find(line, v)
        end
    end
    if not commentPosition then
        return
    end
    local macroStartIndex = string.find(line, self._macroStartTag, 1, true)
    local macroEndIndex = string.find(line, self._macroEndTag, 1, true)
    if not macroStartIndex or not macroEndIndex or macroStartIndex >= macroEndIndex then
        return
    end
    local code = string.sub(line, 1, commentPosition - 1)
    local macro = string.sub(line, macroStartIndex + #self._macroEndTag, macroEndIndex - 1)
    local body = string.explode(macro, "|")
    self:assert(#body > 1, "invalid macro, line, " .. line)
    local command = string.trim(body[1])
    local arguments = {}
    for i=2,#body do
        local argument = string.trim(body[i])
        table.insert(arguments, argument)
    end
    self:assert(self['_COMMAND_' .. command] ~= nil, "command not found : " .. command)
    return self['_COMMAND_' .. command](self, code, arguments)
end

function Builder:start()
    --
    self:print("start:")
    self:assert(not table.is_empty(self._inputFiles), "input files are not defined")
    self:assert(not self._isHandleMacro or is_table(self._commentTags), "comment tags are not defined")
    self:assert(not self._isPrintHeader or is_string(self._headerTag), "header tag is not defined")
    --
    self:print("reading files ...")
    for i,path in ipairs(self._inputFiles) do
        -- read file
        self:assert(files.is_file(path), "file not found:" .. tostring(path))
        local content = files.read(path)
        self:assert(#content > 0, "input files are empty")
        local lineArr = string.explode(content, "\n")
        -- put header file
        table.insert(self._lineArr, "\n")
        if self._isPrintHeader then
            local headInfo = string.format(" date:%s file:%s ", os.date("%Y-%m-%d %H:%M:%S", os.time()), path)
            local headWidth = #headInfo + 10
            local tagLength = #self._headerTag
            self._headerHeight = (self._headerHeight and self._headerHeight > 0) and self._headerHeight or 1
            for _=1,self._headerHeight do
                table.insert(self._lineArr, string.center(self._headerTag, headWidth, self._headerTag))
            end
            table.insert(self._lineArr, string.center(headInfo, headWidth, self._headerTag))
            for _=1,self._headerHeight do
                table.insert(self._lineArr, string.center(self._headerTag, headWidth, self._headerTag))
            end
        end
        table.insert(self._lineArr, "\n")
        -- parse file content
        for _,line in ipairs(lineArr) do
            local newLine = self:_parseLine(line)
            table.insert(self._lineArr, newLine or line)
        end
    end
    --
    self:print("creating target ...")
    local html = table.concat(self._lineArr, "\n")
    self:assert(self._outputFile ~= nil, "output path not found")
    files.write(self._outputFile, html)
    self:print("writing target succeeded!")
    self:print("finish!\n")
end

return Builder
