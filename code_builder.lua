--[[
    code
]]

local Base = require("builder_base")
local Builder, Super = class("CodeBuilder", Base)

function Builder:__init__()
    Super.__init__(self, "code")
    self._lineArr = {}
    self._macroStartTag = "[M["
    self._macroEndTag = "]M]"
end

function Builder:setComment(commentTag)
    self:_print("set comment ...")
    self:_assert(self._commentTag == nil, "comment tag is already defined")
    self._commentTag = commentTag
    self:_print("comment tags:" .. self._commentTag)
    return self
end

function Builder:addHeader(height)
    self:_print("add header ...")
    self:_assert(self._isPrintHeader == nil, "print header is already defined")
    self._isPrintHeader = true
    self._headerPadding = height or 1
    self:_print("header padding:" .. self._headerPadding)
    return self
end

function Builder:handleMacro(value)
    self:_print("handle macro:" .. tostring(value))
    self._isHandleMacro = value == true
    return self
end

function Builder:onMacro(macroCallback)
    self._onMacroCallback = macroCallback
    return self
end

function Builder:onLine(lineCallback)
    self._onLineCallback = lineCallback
    return self
end

function Builder:_COMMAND_FILE_BASE64(code, arguments)
    local filePath = arguments[1]
    self:_assert(files.is_file(filePath), "file not found, path:" .. filePath)
    local content = files.read(filePath)
    local data = encryption.base64_encode(content)
    return string.format(code, data)
end

function Builder:_COMMAND_FILE_PLAIN(code, arguments)
    local filePath = arguments[1]
    self:_assert(files.is_file(filePath), "file not found, path:" .. filePath)
    local content = files.read(filePath)
    return string.format(code, content)
end

function Builder:_COMMAND_FILE_STRING(code, arguments)
    local filePath = arguments[1]
    local escapeTag = arguments[2] or [[]]
    local minimize = arguments[3] ~= nil and string.lower(arguments[3]) == "true"
    filePath = self._projDir .. filePath
    self:_assert(files.is_file(filePath), "file not found, path:" .. filePath)
    local fileContent = files.read(filePath)
    local lineArr = string.explode(fileContent, "\n")
    for i,v in ipairs(lineArr) do
        lineArr[i] = v:gsub("[\n\r]+$", " ")
            :gsub([[\]], string.format([[%s\%s\]], escapeTag, escapeTag))
            :gsub([["]], string.format([[%s\%s"]], escapeTag, escapeTag))
            :gsub([[']], string.format([[%s\%s']], escapeTag, escapeTag))
    end
    local result = table.implode(lineArr, string.format([[ %s\n ]], escapeTag))
    if minimize then
        result = result:gsub("%s+", " ")
    end
    return string.format(code, result)
end

function Builder:_COMMAND_LINE_REFPLACE(code, arguments)
    return arguments[1]
end

function Builder:_parseLine(index, line)
    if not self._isHandleMacro then
        if self._onLineCallback then
            return self._onLineCallback(line)
        end
        return line
    end
    local commentPosition = string.find(line, self._commentTag)
    if not commentPosition then
        if self._onLineCallback then
            return self._onLineCallback(line)
        end
        return line
    end
    local macroStartIndex = string.find(line, self._macroStartTag, 1, true)
    local macroEndIndex = string.find(line, self._macroEndTag, 1, true)
    if not macroStartIndex or not macroEndIndex or macroStartIndex >= macroEndIndex then
        if self._onLineCallback then
            return self._onLineCallback(line)
        end
        return line
    end
    local code = string.sub(line, 1, commentPosition - 1)
    local macro = string.sub(line, macroStartIndex + #self._macroEndTag, macroEndIndex - 1)
    local body = string.explode(macro, "|")
    self:_assert(#body >= 1, "invalid macro, line: " .. line)
    local command = string.trim(body[1])
    local arguments = {}
    for i=2,#body do
        local argument = string.trim(body[i])
        table.insert(arguments, argument)
    end
    if self['_COMMAND_' .. command] then
        return self['_COMMAND_' .. command](self, code, arguments)
    elseif self._onMacroCallback then
        return self._onMacroCallback(code, command, unpack(arguments))
    else
        return line
    end
end

function Builder:start()
    --
    self:_print("start:")
    self:_assert(not table.is_empty(self._inputFiles), "input files are not defined")
    self:_assert(not self._isHandleMacro or is_string(self._commentTag), "comment tag is not defined")
    self:_assert(not self._isPrintHeader or is_string(self._commentTag), "header tag is not defined")
    --
    self:_print("reading files ...")
    for i,path in ipairs(self._inputFiles) do
        -- read file
        self:_assert(files.is_file(path), "file not found:" .. tostring(path))
        local content = files.read(path)
        self:_assert(#content > 0, "input files are empty")
        local lineArr = string.explode(content, "\n")
        -- put header file
        if self._isPrintHeader then
            local headInfo = string.format(" date:%s file:%s ", os.date("%Y-%m-%d %H:%M:%S", os.time()), self._inputNames[i])
            self._headerPadding = (self._headerPadding and self._headerPadding > 0) and self._headerPadding or 0
            for _=1,self._headerPadding do
                table.insert(self._lineArr, "")
            end
            table.insert(self._lineArr, self._commentTag .. headInfo)
            for _=1,self._headerPadding do
                table.insert(self._lineArr, "")
            end
        end
        -- parse file content
        for index,line in ipairs(lineArr) do
            local newLine = self:_parseLine(index, line)
            if is_table(newLine) then
                for i,v in ipairs(newLine) do
                    table.insert(self._lineArr, v)
                end
            elseif is_string(newLine) then
                table.insert(self._lineArr, newLine)
            end
        end
    end
    --
    self:_print("creating target ...")
    local html = table.concat(self._lineArr, "\n")
    self:_assert(self._outputFile ~= nil, "output path not found")
    files.write(self._outputFile, html)
    self:_print("writing target succeeded!")
    self:_print("finish!\n")
    return self
end

return Builder
