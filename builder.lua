--[[
    builder
]]

-- import lua tools
package.path = package.path .. ";../../pure-lua-tools/?.lua"
require('test')

-- import available builders
package.path = package.path .. ";builders/?.lua"
dofile(files.csd() .. "builder_base.lua")
dofile(files.csd() .. "builders/c_builder.lua")
dofile(files.csd() .. "builders/html_builder.lua")
dofile(files.csd() .. "builders/code_builder.lua")

if not rawget(_G, 'builder') then
    rawset(_G, 'builder', {})
end
local builder = rawget(_G, 'builder')
local UI_LENGTH = 25
local tasks = {}

function string.split_by_upper(word)
    local res = {}
    for sub in word:gmatch("%u%l*") do
        table.insert(res, sub)
    end
    return res
end

local function _builder_help(obj)
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

local function _builder_parse(obj, args)
    for k,v in pairs(args) do
        assert(string.valid(k), 'invalid argument key for builder' .. tostring(k))
        local wrds = k:lower():explode("_")
        local name = wrds:reduce(function(accumulator, word)
            return accumulator .. string.upper(string.sub(word, 1, 1)) .. string.sub(word, 2, -1)
        end)
        local func = obj['set' .. name]
        assert(is_function(func), 'unknown argument key for builder:' .. tostring(k))
        func(obj, v)
    end
end

local function _builder_build(cls, argsOrName)
    local obj = cls(false)
    local fun = function(args)
        _builder_parse(obj, args)
        obj.help = _builder_help
        table.insert(tasks, obj)
        return obj
    end
    if is_string(argsOrName) then
        obj:setName(argsOrName)
        return fun
    else
        return fun(argsOrName)
    end
end

function builder.c(...)
    return _builder_build(MyCBuilder, ...)
end

function builder.html(...)
    return _builder_build(MyHtmlBuilder, ...)
end

function builder.code(...)
    return _builder_build(MyCodeBuilder, ...)
end

function builder.help()
    print("-" .. string.center("-", UI_LENGTH, "-") .. "-")
    print("|" .. string.center("builder help", UI_LENGTH, " ") .. "|")
    print("-" .. string.center("-", UI_LENGTH, "-") .. "-")
    print('| builders:')
    for k,v in pairs(builder) do
        print('|', "*", k)
    end
    print("-" .. string.center("-", UI_LENGTH, "-") .. "-")
end

function builder.tasks()
    print("-" .. string.center("-", UI_LENGTH, "-") .. "-")
    print("|" .. string.center("builder list", UI_LENGTH, " ") .. "|")
    print("-" .. string.center("-", UI_LENGTH, "-") .. "-")
    print('| tasks:')
    for i,obj in ipairs(tasks) do
        print('|', i .. ".", obj:getName())
    end
    print("-" .. string.center("-", UI_LENGTH, "-") .. "-")
end

function builder.find(name)
    assert(string.valid(name), 'invalid task name for builder')
    for i,obj in ipairs(tasks) do
        if obj:getName() == name then
            return obj
        end
    end
end


if debug.getinfo(2).name == "require" then
    return builder
elseif files.is_file("./build.lua") then
    require('build')
    local name = arg and arg[1] or "UNKNOWN"
    local obj = builder.find(name)
    if obj then
        obj:start()
    else
        error('task object not found for name: ' .. name)
    end
else
    -- run or create build.lua
    error('build.lua file not found for builder')
end
