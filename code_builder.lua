--[[
    code
]]

local Base = require("builder_base")
local Builder, Super = class("Builder", Base)

function Builder:__init__()
    Super.__init__(self, "html")
    self._fileArr = {}
    self._lineArr = {}
    self:_prepareEnv()
end

function Builder:_prepareEnv()
    Super._prepareEnv(self)
end

function Builder:inputFiles(...)
    self:print("input files ...")
    self:assert(table.is_empty(self._fileArr), "input files are already defined")
    local fileArr = {...}
    for i,v in ipairs(fileArr) do
        self:assert(files.is_file(v), "input file not found:" .. v)
        self:print("input file:" .. v)
        table.insert(self._fileArr, v)
    end
end

function Builder:printHeader(headerTag)
    self:print("print header ...")
    self:assert(self._printHeader == nil, "print header is already defined")
    self:assert(is_string(headerTag), "header tag should be string")
    self._printHeader = true
    self._headerTag = headerTag
    self:print("header tag:" .. tostring(self._headerTag))
end

function Builder:handleMacro(...)
    self:print("handle macro ...")
    self:assert(self._handleMacro == nil, "handle macro is already defined")
    self._handleMacro = true
    self:assert(self._commentTags == nil, "comment tag is already defined")
    self._commentTags = {...}
    self:assert(not table.is_empty(self._commentTags), "comment tag should be string")
    self:print("comment tags:" .. table.implode(self._commentTags, ","))
end

function Builder:outputFile(path)
    self:assert(self._outputFile == nil, "output can only be one file")
    self:assert(is_string(path), "output path should be string")
    self._outputFile = path
end

function Builder:start()
    --
    self:print("start:")
    self:assert(not table.is_empty(self._fileArr), "input files are not defined")
    self:assert(not self._handleMacro or is_table(self._commentTags), "comment tags are not defined")
    self:assert(not self._printHeader or is_string(self._headerTag), "header tag is not defined")

    local content = "test..."
    self:assert(#content > 0, "input file is empty")
    self._lineArr = string.explode(content, "\n")
    --
    --
    self:print("creating target ...")
    local html = table.concat(self._lineArr, "\n")
    self:assert(self._outputFile ~= nil, "output path not found")
    files.write(self._outputFile, html)
    self:print("writing target succeeded!")
    self:print("finish!\n")
end

return Builder
