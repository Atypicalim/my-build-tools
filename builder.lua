--[[
    builder
]]

local CBuilder = require("c_builder")
local HtmlBuilder = require("html_builder")
local CodeBuilder = require("code_builder")

local builder = {}
local UI_LENGTH = 25

function string.split_by_upper(word)
    local res = {}
    for sub in word:gmatch("%u%l*") do
        table.insert(res, sub)
    end
    return res
end

function _builder_help(obj)
    print("-" .. string.center("-", UI_LENGTH, "-") .. "-")
    print("|" .. string.center(obj.__name__ .. " Help", UI_LENGTH, " ") .. "|")
    print("-" .. string.center("-", UI_LENGTH, "-") .. "-")
    local confKeys = {}
    local objFuncs = {}
    local arr = {obj.__class__, obj.__class__.__super__}
    for _,cls in ipairs(arr) do
        for key,val in pairs(cls) do
            if is_function(val) and key:starts("set") then
                local words = string.split_by_upper(key)
                local name = string.implode(words, "_"):lower()
                confKeys[name] = true
            end
            if is_function(val) and not key:starts("_") then
                objFuncs[key] = true
            end
        end
    end
    print('| keys:')
    for key,_ in pairs(confKeys) do
        print("| * " .. key)
    end
    print('| funs:')
    for key,_ in pairs(objFuncs) do
        print("| * " .. key)
    end
    print("-" .. string.center("-", UI_LENGTH, "-") .. "-")
end

function _builder_build(cls, args)
    local obj = cls(false)
    for k,v in pairs(args) do
        assert(string.valid(k), 'invalid argument key for builder' .. tostring(k))
        local wrds = k:lower():explode("_")
        local name = ""
        for i,word in ipairs(wrds) do
            name = name .. string.upper(string.sub(word, 1, 1)) .. string.sub(word, 2, -1)
        end
        local func = obj['set' .. name]
        assert(is_function(func), 'unknown argument key for builder:' .. tostring(k))
        func(obj, v)
    end
    obj.help = _builder_help
    return obj
end

function builder.c(...)
    return _builder_build(CBuilder, ...)
end

function builder.html(...)
    return _builder_build(HtmlBuilder, ...)
end

function builder.code(...)
    return _builder_build(CodeBuilder, ...)
end

function builder.help()
    print("-" .. string.center("-", UI_LENGTH, "-") .. "-")
    print("|" .. string.center("builder help", UI_LENGTH, " ") .. "|")
    print("-" .. string.center("-", UI_LENGTH, "-") .. "-")
    print('| builders:')
    for i,v in pairs(builder) do
        print('|', string.left(tostring(i), 10, " "))
    end
    print("-" .. string.center("-", UI_LENGTH, "-") .. "-")
end

if arg and #arg > 0 then
    -- run or create build.lua
else
    return builder
end
